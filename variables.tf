

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "subnet_configs" {
  description = "A map of subnet configurations."
  type = map(object({
    cidr_block        = string
    availability_zone = string
    assign_public_ip  = optional(bool, false) 
  }))
}

/*
variable "ami_id" {
  description = "The AMI ID to use for the instances."
  type        = string
}
*/

variable "instance_type" {
  description = "The type of instances to launch."
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use."
  type        = string
}
/*
variable "user_data" {
  description = "Script to install application."
  type        = string
  default     = <<-EOF
                  #!/bin/bash
                  sudo apt update
                  sudo apt install -y nginx
                  echo "Hello it's me Esmael" > /var/www/html/index.html
                  sudo systemctl start nginx
                  sudo systemctl enable nginx
                  sudo service nginx restart
                EOF
}
*/
variable "bastion_instance_count" {
  description = "The number of bastion instances to create."
  type        = number
  default     = 1 
}

variable "encryption_key_bits" {
  description = "The number of bits for the encryption key."
  type        = number
}

variable "private_instance_count" {
  description = "The number of private instances to create."
  type        = number
  default     = 2 
}

variable "nat_gateway_name" {
  description = "The name of the NAT gateway."
  type        = string
}

variable "encryption_algorithm" {
  description = "The encryption algorithm to use."
  type        = string
  default     = "RSA" 
}
variable "key_pair_name" {
  description = "The name of the key pair to use."
  type        = string
}

variable "most_recent" {
  description = "Select the most recent AMI."
  type        = bool
  default     = true
}

variable "owners" {
  description = "List of AMI owner IDs."
  type        = list(string)
  default     = ["099720109477"]
}

variable "ami_filter" {
  description = "Filter object for the AMI lookup. Requires 'name' and 'values'."
  type = object({
    name   = string,
    values = list(string)
  })
}
/*
variable "internal_lb_dns" {
  description = "DNS name of the internal load balancer"
  type        = string
}
*/