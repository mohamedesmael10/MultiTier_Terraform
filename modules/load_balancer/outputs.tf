
#output "target_group_arn" {
#  value = aws_lb_target_group.application_tg.arn
#}
/*
output "load_balancer_arn" {
  description = "The ARN of the created load balancer."
  value       = aws_lb.this.arn
}


output "target_group_name" {
  description = "The name of the created target group."
  value       = aws_lb_target_group.this.name
}

*/
output "lb_dns_name" {
  description = "The DNS name of the created load balancer."
  value       = aws_lb.this.dns_name
}