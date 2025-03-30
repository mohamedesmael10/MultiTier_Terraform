output "ami_id" {
  description = "The selected AMI ID."
  value       = data.aws_ami.selected.id
}

output "ami_details" {
  description = "All details of the selected AMI."
  value       = data.aws_ami.selected
}