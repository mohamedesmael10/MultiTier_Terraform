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

resource "aws_instance" "private" {
  count                       = var.private_instance_count > 0 ? var.private_instance_count : 0
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_ids, count.index)
  key_name                    = var.key_name
  associate_public_ip_address = false
  security_groups             = [var.security_group_ids.private]
  user_data                   = var.user_data

  tags = {
    Name = "${var.resource_name}-private-${count.index}"
  }
}

resource "null_resource" "public_instance_provisioners" {
  count = var.bastion_instance_count > 0 ? var.bastion_instance_count : 0

  # Provisioner 1: Copy a key file to the remote bastion instance
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

  # Provisioner 2: Change file permissions on the remote host
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = aws_instance.bastion[count.index].public_ip
    }
    inline = [
      "chmod 400 /home/ubuntu/my-key-pair.pem"
    ]
  }

  # Provisioner 3: Update and install Apache on the remote bastion instance
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

  # Provisioner 4: Copy the entire local web_page directory to /var/www/html/ on the remote host
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)
      host        = aws_instance.bastion[count.index].public_ip
    }
    source      = "./web_page"
    destination = "/var/www/html"
  }

  depends_on = [aws_instance.bastion]
}

resource "null_resource" "print_ips" {
  depends_on = [aws_instance.bastion]

  provisioner "local-exec" {
    command = <<-EOT
      echo "${join("\n", [for i, ip in aws_instance.bastion[*].public_ip : "public-ip${i + 1} ${ip}"])}" > all-ips.txt
    EOT
  }
}
