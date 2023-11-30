resource "aws_autoscaling_group" "web" {

  vpc_zone_identifier = aws_subnet.subnet-oficial[*].id
  
  max_size            = 5
  min_size            = 2
  desired_capacity    = 2
  health_check_type   = "EC2"

  launch_template {
    id = aws_launch_template.web_template.id
    version = "$Latest"

  }

  target_group_arns = [aws_lb_target_group.novo-target.arn]

  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn  = aws_lb_target_group.novo-target.arn
}