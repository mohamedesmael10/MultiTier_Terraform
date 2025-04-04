# Public (Bastion) Instances – created only when bastion_instance_count > 0
resource "aws_instance" "bastion" {
  count                       = var.bastion_instance_count > 0 ? var.bastion_instance_count : 0
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_ids, count.index)
  key_name                    = var.key_name
  associate_public_ip_address = true
  security_groups             = [var.security_group_ids.bastion]

  tags = {
    Name = "${var.resource_name}-bastion-${count.index}"
  }
}

# Private Instances – created only when private_instance_count > 0
resource "aws_instance" "private" {
  count                       = var.private_instance_count > 0 ? var.private_instance_count : 0
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_ids, count.index)
  key_name                    = var.key_name
  associate_public_ip_address = false
  security_groups             = [var.security_group_ids.private]
  #user_data                   = var.user_data

  tags = {
    Name = "${var.resource_name}-private-${count.index}"
  }
}

#############################
# Provisioning for Bastion (Public) Instances
#############################
resource "null_resource" "bastion_provisioners" {
  count = var.bastion_instance_count > 0 ? var.bastion_instance_count : 0

  # Copy a key file to the bastion
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = aws_instance.bastion[count.index].public_ip
    }
    source      = "./my-key-pair.pem"
    destination = "/home/ubuntu/my-key-pair.pem"
  }

  # Change key file permissions on the bastion
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = aws_instance.bastion[count.index].public_ip
    }
    inline = [
      "chmod 600 /home/ubuntu/my-key-pair.pem"
    ]
  }

  # Update and install Apache on the bastion
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = aws_instance.bastion[count.index].public_ip
    }
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "sudo systemctl restart apache2"
    ]
  }

  depends_on = [aws_instance.bastion]
}

#############################
# Provisioning for Private Instances
# Uses a jump host specified via var.bastion_host_ip.
#############################
resource "null_resource" "private_provisioners" {
  count = var.private_instance_count > 0 ? var.private_instance_count : 0

  # Update and install Apache on the private instance using the bastion as jump host
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = file(var.key)
      host                = aws_instance.private[count.index].private_ip
      bastion_host        = var.bastion_host_ip
      bastion_user        = "ubuntu"
      bastion_private_key = file(var.key)
    }
    inline = [
    "set -e",  // Exit immediately if a command exits with a non-zero status
    "echo 'Updating apt-get...'",
    "sudo apt-get update -y",
    "echo 'Installing apache2...'",
    "sudo apt-get install -y apache2",
    "echo 'Starting apache2...'",
    "sudo systemctl start apache2",
    "sudo systemctl enable apache2",
    "sudo mkdir -p /var/www/html",
    "sudo chown -R ubuntu:ubuntu /var/www/html",
    "sudo systemctl restart apache2",
    "echo 'Apache installation complete.'"
  ]
  }

  # Copy the local web_page directory to /var/www/html on the private instance using the bastion as jump host
  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = file(var.key)
      host                = aws_instance.private[count.index].private_ip
      bastion_host        = var.bastion_host_ip
      bastion_user        = "ubuntu"
      bastion_private_key = file(var.key)
    }
    source      = "./web_page/"
    destination = "/var/www/html"
  }

  depends_on = [aws_instance.private, aws_instance.bastion]
}


