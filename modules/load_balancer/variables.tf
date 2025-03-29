variable "is_internal" {
  description = "Indicates whether the load balancer is internal or external."
  type        = bool
}

variable "security_group_ids" {
  description = "The security groups to associate with the load balancer."
  type        = list(string)
}

variable "resource_name" {
  description = "The base name for all resources."
  type        = string
}

variable "load_balancer_name" {
  description = "The name of the load balancer."
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs for the load balancer."
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the load balancer is located"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to attach to the load balancer target group"
  type        = list(string)
}
