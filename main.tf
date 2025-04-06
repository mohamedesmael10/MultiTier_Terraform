module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "subnet" {
  source         = "./modules/subnet"
  vpc_id         = module.vpc.vpc_id
  subnet_configs = var.subnet_configs

  depends_on = [module.vpc]
}

module "internet_gateway" {
  source       = "./modules/internet_gateway"
  vpc_id_input = module.vpc.vpc_id
  gateway_name = "${var.project_name}-igw"


  depends_on = [module.vpc]
}

module "nat_gateway" {
  source            = "./modules/nat_gateway"
  nat_gateway_name  = "${var.project_name}-nat-gw"
  public_subnet_ids = module.subnet.public_subnets

  depends_on = [module.subnet, module.internet_gateway]
}

module "route_table" {
  source                    = "./modules/route_table"
  vpc_id_input              = module.vpc.vpc_id
  internet_gateway_id_input = module.internet_gateway.internet_gateway_id
  nat_gateway_ids           = module.nat_gateway.nat_gateway_ids
  public_subnet_ids         = module.subnet.public_subnets
  private_subnet_ids        = module.subnet.private_subnets
  route_table_name          = "${var.project_name}-route-table"

  depends_on = [
    module.vpc,
    module.subnet,
    module.internet_gateway,
    module.nat_gateway
  ]
}

module "keyPair" {
  source               = "./modules/key_pair"
  key_pair_name        = "my-key-pair.pem"
  encryption_algorithm = "RSA"
  encryption_key_bits  = 4096

  depends_on = [module.vpc]
}

module "security_group" {
  source        = "./modules/security_group"
  resource_name = var.project_name
  vpc_id        = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "public_instances" {
  source                 = "./modules/instance"
  resource_name          = var.project_name
  private_instance_count = 0
  bastion_instance_count = var.bastion_instance_count
  #user_data              = var.user_data
  ami_id         = module.data_source.ami_id
  instance_type  = var.instance_type
  subnet_ids     = module.subnet.public_subnets 
  subnet_configs = var.subnet_configs
  security_group_ids = {
    bastion       = module.security_group.bastion_security_group_id
    private       = module.security_group.private_instance_security_group_id
    load_balancer = module.security_group.load_balancer_security_group_id
  }
  key_name        = var.key_pair_name
  bastion_host_ip = ""
  depends_on = [
    module.subnet,
    module.security_group,
    module.route_table,
    module.data_source,
    module.security_group
  ]
}
module "data_source" {
  source      = "./modules/data_source"
  most_recent = var.most_recent
  owners      = var.owners
  ami_filter  = var.ami_filter
}

module "private_instances" {
  source                 = "./modules/instance"
  resource_name          = var.project_name
  private_instance_count = var.private_instance_count
  bastion_instance_count = 0
  ami_id         = module.data_source.ami_id
  instance_type  = var.instance_type
  subnet_ids     = module.subnet.private_subnets 
  subnet_configs = var.subnet_configs
  security_group_ids = {
    bastion       = module.security_group.bastion_security_group_id
    private       = module.security_group.private_instance_security_group_id
    load_balancer = module.security_group.load_balancer_security_group_id
  }
  key_name = var.key_pair_name
  #user_data                  = var.user_data
  bastion_host_ip = module.public_instances.public_instance_ips[0]
  depends_on = [
    module.subnet,
    module.public_instances,
    module.nat_gateway,
    module.route_table,
    module.data_source,
    module.security_group,
  ]
}


module "Public_load_balancer" {
  source      = "./modules/load_balancer"
  is_internal = false
  security_group_ids = [
    module.security_group.bastion_security_group_id,
    module.security_group.private_instance_security_group_id,
    module.security_group.load_balancer_security_group_id
  ]
  resource_name      = var.project_name
  load_balancer_name = "${var.project_name}-Public-lb"
  subnet_ids         = module.subnet.public_subnets
  vpc_id             = module.vpc.vpc_id

  instance_ids = module.public_instances.public_instance_ids

  depends_on = [
    module.public_instances,
    module.security_group,
    module.route_table
  ]
}

module "Private_load_balancer" {
  source      = "./modules/load_balancer"
  is_internal = true
  security_group_ids = [
    module.security_group.bastion_security_group_id,
    module.security_group.private_instance_security_group_id,
    module.security_group.load_balancer_security_group_id
  ]
  resource_name      = var.project_name
  load_balancer_name = "${var.project_name}-lb"
  subnet_ids         = module.subnet.private_subnets
  vpc_id             = module.vpc.vpc_id

  instance_ids = module.private_instances.private_instance_ids

  depends_on = [
    module.public_instances,
    module.private_instances,
    module.security_group,
    module.route_table,
  ]
}


resource "null_resource" "configure_reverse_proxy" {
  count = length(module.public_instances.public_instance_ips)

  triggers = {
    internal_lb_dns = module.Private_load_balancer.lb_dns_name
  }

  depends_on = [
    module.Public_load_balancer,
    module.Private_load_balancer,
    module.public_instances
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_pair_name)
      host        = module.public_instances.public_instance_ips[count.index]
    }
    inline = [
      "sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/000-default.conf\n<VirtualHost *:80>\n  ProxyPreserveHost On\n  ProxyPass / http://${module.Private_load_balancer.lb_dns_name}/\n  ProxyPassReverse / http://${module.Private_load_balancer.lb_dns_name}/\n</VirtualHost>\nEOF'",
      "sudo systemctl restart apache2"
    ]
  }
}

module "print_ips" {
  source       = "./modules/print_ips"
  instance_ips = module.public_instances.public_instance_ips
  lb_dns       = module.Public_load_balancer.lb_dns_name
  output_file  = "all-ips.txt"
  depends_on   = [module.public_instances, module.Public_load_balancer]
}
