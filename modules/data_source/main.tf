data "aws_ami" "selected" {
  most_recent = var.most_recent
  owners      = var.owners

  dynamic "filter" {
    for_each = var.filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}
