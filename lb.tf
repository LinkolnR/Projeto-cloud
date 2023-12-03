
# Criando um Target group
resource "aws_lb_target_group" "novo-target" {
  name        = "novo-target"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.VPC-oficial.id  

  health_check {
    path                = "/docs"
    port                = 8080
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 2
  }
}
# Criando um Load Balancer
resource "aws_lb" "load-balancer" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.securityGroupLoad.id]  # Substitua pelo ID do seu Security Group
  subnets            = aws_subnet.subnet-oficial[*].id      # Substitua pelo ID da sua Subnet

  enable_deletion_protection         = false
  enable_cross_zone_load_balancing   = true
  enable_http2                      = true
}
# Associando o Target Group ao Load Balancer
resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.novo-target.arn
  }
}
