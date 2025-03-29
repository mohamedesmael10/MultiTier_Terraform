resource "aws_instance" "bastion" {
  count = var.bastion_instance_count > 0 ? var.bastion_instance_count : 0

  ami                    = var.ami_id
  instance_type          = var.instance_type

  # Directly reference the public subnets output
  subnet_id              = element(var.subnet_ids, count.index)

  key_name               = var.key_name
  associate_public_ip_address = true

  security_groups        = [var.security_group_ids.bastion]

  tags = {
    Name = "${var.resource_name}-bastion-${count.index}"
  }
  
  # Remote provisioner: install Apache (or a proxy)
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apache2"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "private" {
  count = var.private_instance_count > 0 ? var.private_instance_count : 0

  ami                    = var.ami_id
  instance_type          = var.instance_type

  # Directly reference the private subnets output
  subnet_id              = element(var.subnet_ids, count.index)

  key_name               = var.key_name
  associate_public_ip_address = false

  security_groups        = [var.security_group_ids.private]

  user_data              = var.user_data
  
  tags = {
    Name = "${var.resource_name}-private-${count.index}"
  }
}

resource "null_resource" "public_instance_provisioners" {
  count = var.bastion_instance_count > 0 ? var.bastion_instance_count : 0

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.key)
    host        = aws_instance.bastion[count.index].public_ip
  }

  # Example: copy a key file and change its permissions (if needed)
  provisioner "file" {
    source      = "./my-key-pair.pem"
    destination = "/home/ubuntu/my-key-pair.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/my-key-pair.pem"
    ]
  }

  depends_on = [aws_instance.bastion]
}

resource "null_resource" "print_ips" {
  depends_on = [aws_instance.bastion]

  provisioner "local-exec" {
    # This command uses Terraform's interpolation to join the bastion public IPs,
    # then writes them to all-ips.txt with the desired format.
    command = "echo '${join(\"\\n\", [for idx, ip in aws_instance.bastion[*].public_ip : format(\"public-ip%d %s\", idx+1, ip)])}' > all-ips.txt"
  }
}
