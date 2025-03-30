variable "vpc_id_input" {
  description = "The VPC ID."
  type        = string
}

variable "internet_gateway_id_input" {
  description = "The Internet Gateway ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "nat_gateway_ids" {
  description = "List of NAT gateway IDs to be used for private subnets."
  type        = list(string)
}

variable "route_table_name" {
  description = "Name for the route table(s)."
  type        = string
}
