variable "vpc_id_input" {
  description = "The ID of the VPC for the route tables"
  type        = string
}

variable "internet_gateway_id_input" {
  description = "The ID of the Internet Gateway for public routing"
  type        = string
}

variable "nat_gateway_id_input" {
  description = "The ID of the NAT Gateway for private routing"
  type        = string
}

variable "route_table_name" {
  description = "The name for the route tables"
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs to associate with the public route table"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs to associate with the private route table"
  type        = list(string)
}

variable "bastion_instance_count" {
  description = "The number of bastion instances to create."
  type        = number
  default     = 1  
}
