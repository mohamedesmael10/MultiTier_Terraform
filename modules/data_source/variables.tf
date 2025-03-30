variable "most_recent" {
  description = "Select the most recent AMI."
  type        = bool
  default     = true
}

variable "owners" {
  description = "List of AMI owner IDs."
  type        = list(string)
  default     = ["099720109477"]
}

variable "ami_filter" {
  description = "Filter object for the AMI lookup. Requires 'name' and 'values'."
  type = object({
    name   = string,
    values = list(string)
  })
  default = {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}