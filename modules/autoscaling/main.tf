resource "aws_autoscaling_group" "main" {
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  capacity_rebalance        = "false"
  default_cooldown          = "300"
  default_instance_warmup   = "0"
  enabled_metrics           = ["GroupAndWarmPoolDesiredCapacity", "GroupAndWarmPoolTotalCapacity", "GroupDesiredCapacity", "GroupInServiceCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingCapacity", "GroupPendingInstances", "GroupStandbyCapacity", "GroupStandbyInstances", "GroupTerminatingCapacity", "GroupTerminatingInstances", "GroupTotalCapacity", "GroupTotalInstances", "WarmPoolDesiredCapacity", "WarmPoolMinSize", "WarmPoolPendingCapacity", "WarmPoolTerminatingCapacity", "WarmPoolTotalCapacity", "WarmPoolWarmedCapacity"]
  force_delete              = "false"
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  max_instance_lifetime = "0"
  metrics_granularity   = "1Minute"

  name                    = var.name
  service_linked_role_arn = "arn:aws:iam::312812643817:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  target_group_arns       = [var.target_group_arn]
  vpc_zone_identifier     = [var.subnets[0].subnet.id, var.subnets[1].subnet.id]

  wait_for_capacity_timeout = "10m"
}
