variable "vpc_id" {
  description = "The ID of the VPC where the subnets will be created"
  type        = string
}

variable "subnet_configs" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    assign_public_ip  = bool
  }))
}
