variable "nat_gateway_name" {
  description = "The name for the NAT Gateway"
  type        = string
}

variable "public_subnet_id_input" {
  description = "The ID of the public subnet where the NAT Gateway will be deployed"
  type        = string
}
