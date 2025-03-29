output "public_route_table_id" {
  value = aws_route_table.public_route.id
}

output "private_route_table_id" {
  value = aws_route_table.private_route.id
}
