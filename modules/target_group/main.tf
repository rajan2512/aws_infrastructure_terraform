
resource "aws_lb_target_group" "main" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200"
    path                = var.path
    port                = "traffic-port"
    protocol            = var.protocol
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = var.name
  port                          = var.port
  protocol                      = var.protocol

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = var.target_type
  vpc_id      = var.vpc_id
}
resource "aws_lb_listener" "listener" {
  default_action {
    order            = "1"
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }

  load_balancer_arn = var.target_id
  port              = "80"
  protocol          = "HTTP"
}
# resource "aws_lb_target_group_attachment" "main" {
#   target_group_arn = aws_lb_target_group.main.arn
#   target_id        = var.target_id
# }

resource "aws_lb_listener_rule" "main" {
  action {
    order            = "1"
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = ["12345"]
    }
  }

  listener_arn = aws_lb_listener.listener.arn
  priority     = "1"
}

