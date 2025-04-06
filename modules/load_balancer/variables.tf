variable "load_balancer_name" {
  description = "The name for the load balancer."
  type        = string
}

variable "is_internal" {
  description = "True for an internal LB, false for public."
  type        = bool
}

variable "subnet_ids" {
  description = "Subnets in which to place the LB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups to attach to the LB."
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID for the target group."
  type        = string
}

variable "instance_ids" {
  description = "Instance IDs to register in the target group."
  type        = list(string)
}

variable "resource_name" {
  description = "Base resource name (used to build TG names)."
  type        = string
}
