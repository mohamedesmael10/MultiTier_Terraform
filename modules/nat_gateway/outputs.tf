output "nat_gateway_ids" {
  description = "List of NAT gateway IDs."
  value       = aws_nat_gateway.nat_gateway[*].id
}
