resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  security_groups    = var.security_groups
  idle_timeout       = var.idle_timeout
  enable_http2       = var.enable_http2

  dynamic "subnet_mapping" {
    for_each = var.subnets
    content {
      subnet_id = subnet_mapping.value.subnet.id
    }
  }

}

# resource "aws_lb_listener" "main" {
#   default_action {
#     fixed_response {
#       content_type = "text/plain"
#       status_code  = "403"
#     }
#     order = "1"
#     type  = "fixed-response"
#   }
#   load_balancer_arn = aws_lb.main.arn
#   port              = "80"
#   protocol          = "HTTP"
# }
# resource "aws_lb_listener" "main" {
#   default_action {
#     order            = "1"
#     target_group_arn = aws_lb_target_group.main.arn
#     type             = "forward"
#   }

#   load_balancer_arn = aws_lb.main.arn
#   port              = "80"
#   protocol          = "HTTP"
# }
