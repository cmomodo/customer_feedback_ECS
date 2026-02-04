#output for load balancer
output "coderco_alb_dns" {
  value     = aws_lb.coderco_alb.dns_name
  sensitive = true
}
output "alb_dns_name" {
  value = aws_lb.coderco_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.coderco_alb.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.coderco_alb.arn
}
