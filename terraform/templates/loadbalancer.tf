resource "aws_lb_target_group" "alb_tg" {
  name                          = "djr-alb-tg"
  target_type                   = "instance"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = "vpc-053064bed55aeba87"
  load_balancing_algorithm_type = "round_robin" #"least_outstanding_requests"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 20
    port                = 80
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "alb" {
    name            = "djr-alb"
    security_groups = ["sg-071dcd71265400b32"] # currently set to default vpc default security group id
    subnets         = ["subnet-09a87d3a7c50a9c0d", "subnet-06b6bd5bb7b191cfd"]
    internal           = false
    load_balancer_type = "application"
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    target_id        = aws_lb.alb.arn
    port             = 80
}

resource "aws_lb_listener" "lb_listener_http" {
    load_balancer_arn    = aws_lb.alb.id
    port                 = "80"
    protocol             = "HTTP"
    default_action {
        target_group_arn = aws_lb_target_group.alb_tg.id
        type             = "forward"
    }
}