#output for load balancer
output "coderco_alb_dns" {
  value     = aws_lb.coderco_alb.dns_name
  sensitive = true
}

#alb dns name for manual debugging
output "alb_dns_name" {
  value = aws_lb.coderco_alb.dns_name
}

#alb zone id
output "alb_zone_id" {
  value = aws_lb.coderco_alb.zone_id
}

#the target group arn
output "target_group_arn" {
  value = aws_lb_target_group.coderco_alb.arn
}
