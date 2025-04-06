locals {
  public_instance_ips = join("\n", [
    for idx, inst in var.instance_ips : "public instance ${idx + 1} public-ip ${inst} user ubuntu"
  ])

  all_ips_content = "${local.public_instance_ips}\nLoad Balancer Public DNS: ${var.lb_dns}"
}

resource "null_resource" "print_ips" {
  provisioner "local-exec" {
    command = "echo -e '${local.all_ips_content}' > ${var.output_file}"
  }
}
