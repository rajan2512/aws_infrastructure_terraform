resource "aws_launch_template" "lc_name" {
  name                   = var.lc_name
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = var.user_data
  vpc_security_group_ids = var.security_group_ids

  monitoring {
    enabled = var.enable_monitoring
  }
}
