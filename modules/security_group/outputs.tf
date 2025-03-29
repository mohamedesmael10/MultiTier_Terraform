output "load_balancer_security_group_id" {
  value = aws_security_group.load_balancer_sg.id
}

output "private_instance_security_group_id" {
  value = aws_security_group.private_instance_sg.id
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion_sg.id
}

