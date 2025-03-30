vpc_cidr     = "10.0.0.0/16"
project_name = "EsmaelTF"

subnet_configs = {
  "public_subnet_1" = {
    cidr_block        = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    assign_public_ip  = true
  },
  "public_subnet_2" = {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    assign_public_ip  = true
  },
  "private_subnet_1" = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    assign_public_ip  = false
  },
  "private_subnet_2" = {
    cidr_block        = "10.0.3.0/24"
    availability_zone = "us-east-1b"
    assign_public_ip  = false
  }
}

#ami_id        = module.data_source.ami_id # Replace with your actual AMI ID
instance_type = "t2.micro"
key_name      = "my-key-pair" # Replace with your actual key name

bastion_instance_count = 2
private_instance_count = 2
/*
user_data = <<-EOF
            #!/bin/bash
            sudo apt update
            sudo apt install -y nginx
            echo "Welcome to Esmael`s EC2" > /var/www/html/index.html
            sudo systemctl start nginx
            sudo systemctl enable nginx
            sudo service nginx restart 
            EOF
*/
nat_gateway_name       = "EsmaelTerraform-nat-gw"
public_subnet_id_input = module.subnet.public_subnets[0] # Ensure this is correctly output from subnet module
key_pair_name          = "my-key-pair"
encryption_algorithm   = "RSA"
encryption_key_bits    = 4096



most_recent = true

owners = ["099720109477"]

ami_filter = {
  name   = "name"
  values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}