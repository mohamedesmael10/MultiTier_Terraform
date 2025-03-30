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
  source                 = "./modules/nat_gateway"
  nat_gateway_name       = "${var.project_name}-nat-gw"
  public_subnet_id_input = module.subnet.public_subnets[0]

  depends_on = [module.subnet, module.internet_gateway]
}
module "route_table" {
  source                    = "./modules/route_table"
  vpc_id_input              = module.vpc.vpc_id
  internet_gateway_id_input = module.internet_gateway.internet_gateway_id
  nat_gateway_id_input      = module.nat_gateway.nat_gateway_id
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
  key_pair_name        = "my-key-pair"
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
  subnet_ids     = module.subnet.public_subnets # Change this line
  subnet_configs = var.subnet_configs
  security_group_ids = {
    bastion       = module.security_group.bastion_security_group_id
    private       = module.security_group.private_instance_security_group_id
    load_balancer = module.security_group.load_balancer_security_group_id
  }
  key_name = var.key_pair_name

  # Ensure public instances are created after the subnets, security groups, and route table
  depends_on = [
    module.subnet,
    module.security_group,
    module.route_table,
    module.data_source
  ]
}
module "data_source" {
  source      = "./modules/data_source"
  most_recent = var.most_recent
  owners      = var.owners
  ami_filter     = var.ami_filter
}

module "private_instances" {
  source                 = "./modules/instance"
  resource_name          = var.project_name
  private_instance_count = var.private_instance_count
  bastion_instance_count = 0

  ami_id         = module.data_source.ami_id
  instance_type  = var.instance_type
  subnet_ids     = module.subnet.private_subnets # Change this line
  subnet_configs = var.subnet_configs
  security_group_ids = {
    bastion       = module.security_group.bastion_security_group_id
    private       = module.security_group.private_instance_security_group_id
    load_balancer = module.security_group.load_balancer_security_group_id
  }
  key_name = var.key_pair_name
  #user_data                  = var.user_data

  # Ensure private instances are created after the subnets, security groups, NAT gateway, and route table
  depends_on = [
    module.subnet,
    module.nat_gateway,
    module.route_table,
    module.data_source
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
  load_balancer_name = "${var.project_name}-Private-lb"
  subnet_ids         = module.subnet.private_subnets
  vpc_id             = module.vpc.vpc_id

  instance_ids = module.private_instances.private_instance_ids

  depends_on = [
    module.public_instances,
    module.security_group,
    module.route_table
  ]
}