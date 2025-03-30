output "public_instance_ips" {
  description = "List of public IP addresses for bastion instances."
  value       = aws_instance.bastion[*].public_ip
}

output "public_instance_ids" {
  description = "List of instance IDs for bastion instances."
  value       = aws_instance.bastion[*].id
}


output "private_instance_ids" {
  description = "List of private instance IDs"
  value       = aws_instance.private[*].id
}
