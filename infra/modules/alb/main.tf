#the load balancer
resource "aws_lb" "coderco_alb" {
  name               = "coderco-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false



}

#target group for load load_balancer
resource "aws_lb_target_group" "coderco_alb" {
  name        = "coderco-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/_health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

#listener for load balancer - HTTPS on 443
resource "aws_lb_listener" "coderco_alb" {
  port              = "443"
  protocol          = "HTTPS"
  load_balancer_arn = aws_lb.coderco_alb.arn
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.coderco_alb.arn
  }

}

# HTTP to HTTPS redirect
resource "aws_lb_listener" "coderco_alb_http_redirect" {
  port              = "80"
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.coderco_alb.arn

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
