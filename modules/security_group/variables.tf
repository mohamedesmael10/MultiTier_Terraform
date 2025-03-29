variable "resource_name" {
  description = "A base name for all resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created"
  type        = string
}
