variable "instance_ips" {
  description = "List of public instance IPs."
  type        = list(string)
}

variable "lb_dns" {
  description = "Load Balancer DNS name."
  type        = string
}


variable "output_file" {
  description = "The file to write the IPs to."
  type        = string
  default     = "all-ips.txt"
}