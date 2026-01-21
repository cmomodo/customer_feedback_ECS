#the load balancer
resource "aws_lb" "coderco_alb" {
  name               = "coderco-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_default_security_group.ecs_security_group.id]
  subnets            = [aws_subnet.secondary_subnet.id]

  enable_deletion_protection = false
  depends_on                 = [aws_vpc.coderco_vpc]



  tags = {
    Environment = "test"
  }
}

#target group for load load_balancer
resource "aws_lb_target_group" "coderco_alb" {
  name                 = "coderco-tg"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = aws_vpc.coderco_vpc.id

  deregistration_delay = 30

}

# #listener for load balancer.
# resource "aws_lb_listener" "coderco_alb" {
#   port              = "3000"
#   protocol          = "HTTP"
#   load_balancer_arn = aws_lb.coderco_alb.arn
#   vpc_id            = aws_vpc.coderco_vpc.id


# }
