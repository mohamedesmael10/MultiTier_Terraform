resource "aws_lb" "this" {
  name               = var.load_balancer_name
  internal           = var.is_internal
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  tags = {
    Name = var.load_balancer_name
  }
}

resource "aws_lb_target_group" "this" {
  name     = substr("${var.resource_name}-${var.is_internal ? "priv-tg" : "pub-tg"}", 0, 32)
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
}
