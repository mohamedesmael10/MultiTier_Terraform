variable "nat_gateway_name" {
  description = "Name for the NAT gateway(s)."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs in which to create NAT gateways."
  type        = list(string)
}
