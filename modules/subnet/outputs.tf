output "subnet_ids_by_name" {
  description = "Map of subnet Name to subnet IDs."
  value       = { for subnet_key, subnet in aws_subnet.subnets : subnet_key => subnet.id }
}

output "public_subnets" {
  value = [for key, subnet in aws_subnet.subnets : subnet.id if subnet.map_public_ip_on_launch]
  description = "A list of IDs for public subnets."
}

output "private_subnets" {
  value = [for key, subnet in aws_subnet.subnets : subnet.id if !subnet.map_public_ip_on_launch]
  description = "A list of IDs for private subnets."
}
