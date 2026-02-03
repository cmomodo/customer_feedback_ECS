#output for load balancer
output "coderco_alb_dns" {
  value = aws_lb.coderco_alb.dns_name
}
