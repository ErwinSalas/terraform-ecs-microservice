# alb.tf

resource "aws_alb" "product_lb" {
  name            = "product-load-balancer"
  subnets         = var.private_subnets
  security_groups = [aws_security_group.lb_sg.id]
}

resource "aws_alb_target_group" "product_tg" {
  name        = "product-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.product_lb.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.product_tg.arn
    type             = "forward"
  }
}

# ALB security Group: Edit to restrict access to the application
resource "aws_security_group" "lb_sg" {
  name        = "product-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}