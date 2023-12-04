# Output for the ALB endpoint
output "alb_endpoint" {
  value = "${aws_lb.load-balancer.dns_name}/docs"
}