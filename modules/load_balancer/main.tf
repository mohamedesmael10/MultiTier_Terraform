# Load Balancer
resource "aws_lb" "application_lb" {
  name               = var.load_balancer_name
  internal           = var.is_internal
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  tags = {
    Name = var.load_balancer_name
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_tg.arn
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "application_tg" {
  name     = "${var.resource_name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Load Balancer Target Group Attachment
resource "aws_lb_target_group_attachment" "instance_attachment" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.application_tg.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
}