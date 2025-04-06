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
  #user_data                   = var.user_data

  tags = {
    Name = "${var.resource_name}-private-${count.index}"
  }
}

resource "time_sleep" "wait_for_instance" {
create_duration = "60s"
depends_on = [aws_instance.private, aws_instance.bastion]

}

resource "null_resource" "bastion_provisioners" {
  count = var.bastion_instance_count > 0 ? var.bastion_instance_count : 0

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
      "sudo a2enmod proxy proxy_http",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "sudo systemctl restart apache2"
    ]
  }

  depends_on = [aws_instance.bastion]

}


resource "null_resource" "private_provisioners" {
  count = var.private_instance_count > 0 ? var.private_instance_count : 0

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
    "set -e", 
    "sudo apt-get update -y",
    "sudo apt-get update --fix-missing -y",
    "sudo apt-get install -y -f apache2",
    "sudo systemctl start apache2",
    "sudo systemctl enable apache2",
    "sudo mkdir -p /var/www/html",
    "sudo chown -R ubuntu:ubuntu /var/www/html",
    "sudo systemctl restart apache2",  ]
  }

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


