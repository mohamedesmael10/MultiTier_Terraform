data "aws_ami" "selected" {
  most_recent = var.most_recent
  owners      = var.owners

  filter {
    name   = var.ami_filter.name
    values = var.ami_filter.values
  }
}