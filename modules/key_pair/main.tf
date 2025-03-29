# Generate a private key
resource "tls_private_key" "generated_private_key" {
  algorithm = var.encryption_algorithm
  rsa_bits  = var.encryption_key_bits
}

# Define the AWS Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.generated_private_key.public_key_openssh
}

# Generate and save the private key file
resource "null_resource" "create_private_key_file" {
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.generated_private_key.private_key_pem}' > ${var.key_pair_name}.pem
      chmod 400 ${var.key_pair_name}.pem
    EOT
  }

}
