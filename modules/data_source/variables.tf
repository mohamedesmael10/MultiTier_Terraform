variable "most_recent" {
  description = "Select the most recent AMI."
  type        = bool
  default     = true
}

variable "owners" {
  description = "A list of AMI owners to filter by."
  type        = list(string)
  default     = ["099720109477"]  # Canonical official account for Ubuntu
}

variable "filters" {
  description = "A list of filter objects to filter the AMI. Each filter is an object with a 'name' and 'values' (list of strings)."
  type = list(object({
    name   = string,
    values = list(string)
  }))
  default = [
    {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-24.04-amd64-server-*"]
    },
    {
      name   = "virtualization-type"
      values = ["hvm"]
    }
  ]
}
