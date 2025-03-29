variable "vpc_id_input" {
  description = "The ID of the VPC to attach the Internet Gateway to"
  type        = string
}

variable "gateway_name" {
  description = "The name for the Internet Gateway"
  type        = string
}
