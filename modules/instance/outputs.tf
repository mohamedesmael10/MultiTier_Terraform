output "bastion_instance_ids" {
  value = aws_instance.bastion[*].id
}

output "private_instance_ids" {
  value = aws_instance.private[*].id
}
