#the load balancer
resource "aws_lb" "coderco_alb" {
  name               = "coderco-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_security_group.id]
  subnets            = [aws_subnet.secondary_subnet.id]

  enable_deletion_protection = false



  tags = {
    Environment = "test"
  }
}

#target group for load load_balancer
resource "aws_lb_target_group" "coderco_tg" {
  name     = "coderco-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.coderco_vpc.id

}

#listener for load balancer.
resource "aws_lb_listener" "front_end" {
  port              = "3000"
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.coderco_alb.arn
  vpc_id            = aws_vpc.coderco_vpc.id

  #health check
  health_check {
      path = "/api/1/resolve/default?path=/service/my-service"
      port = 2001
      healthy_threshold = 6
      unhealthy_threshold = 2
      timeout = 2
      interval = 5
      matcher = "200"  # has to be HTTP 200 or fails
    }
}
