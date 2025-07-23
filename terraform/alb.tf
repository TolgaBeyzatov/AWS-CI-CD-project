### This file describes the Load Balancer resources: ALB, ALB target group, ALB listener.

# Defining the Application Load Balancer
resource "aws_alb" "application_load_balancer" {
  name               = "vpro-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  security_groups    = [aws_security_group.allow_access_ecs_service.id]
}

# Defining the target group and a health check on the application
resource "aws_lb_target_group" "target_group" {
  name        = "vpro-tg"
  port        = 8080 #container port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    path                = "/login"
    protocol            = "HTTP"
    matcher             = "200"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }
}

data "aws_acm_certificate" "issued" {
  domain   = "*.tfbbb.xyz"
  statuses = ["ISSUED"]
}

# Defines an HTTP Listener for the ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"



  # # Defines an HTTPS Listener for the ALB
  # resource "aws_lb_listener" "listener" {
  #   load_balancer_arn = aws_alb.application_load_balancer.arn
  #   port              = "443"
  #   protocol          = "HTTPS"
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = data.aws_acm_certificate.issued.arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

}
