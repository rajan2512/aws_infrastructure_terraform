
locals {
  efs_dns_name           = local.failover ? data.aws_efs_file_system.replica[0].dns_name : module.create_efs_drive.efs_dns_name
  key_pair_name          = "AppServerA"
  load_balancer_arn      = module.create_load_balancer.load_balancer_arn
  load_balancer_dns_name = module.create_load_balancer.load_balancer_dns_name

}
module "create_efs_drive" {
  source = "./modules/efs"
  depends_on = [
    module.RDSSecurityGroup, module.create_private_subnets
  ]

  name            = "efs${local.name_sufix}"
  encrypted       = true
  private_subnets = tolist(local.exported_private_subnets)
  security_groups = [local.efs_security_group_id]
  efs_replica_id  = false
  failover        = local.failover
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
}

# If failover get the replica data
data "aws_efs_file_system" "replica" {
  count = local.failover ? 1 : 0

  tags = {
    Name = "failover"
  }
}

module "create_launch_template" {
  source = "./modules/launch-template"
  depends_on = [
    data.aws_ami.amazon_linux_2, module.create_efs_drive
  ]

  lc_name            = "LaunchTemplate"
  image_id           = data.aws_ami.amazon_linux_2.id
  instance_type      = "t2.micro"
  key_name           = local.key_pair_name
  security_group_ids = [local.app_security_group_id]
  enable_monitoring  = true

  user_data = base64encode(<<EOF
  #!/bin/bash

  # Install Apache Web Server and PHP
  yum install -y httpd mysql
  amazon-linux-extras install -y php7.2

  # mount file system
  yum install -y amazon-efs-utils
  new_file_system="${local.efs_dns_name}:/ /var/www/html/ nfs defaults,_netdev 0 0"
  echo $new_file_system | sudo  tee -a  /etc/fstab
  mount -fav
  mount -t efs ${local.efs_dns_name} /var/www/html/

  # Download Lab files
  wget https://image-resize-launchpad.s3.eu-central-1.amazonaws.com/${local.enviroment}/image-resizer-app.zip
  unzip -n image-resizer-app.zip -d /var/www/html/

  # Download and install the AWS SDK for PHP
  wget https://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip
  unzip -n aws -d /var/www/html

  #give permissions to apache user
  usermod -a -G apache ec2-user
  chown -R ec2-user:apache /var/www
  chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
  find /var/www -type f -exec sudo chmod 0664 {} \;

  # Turn on web server
  chkconfig httpd on
  service httpd start
EOF
  )

}

module "create_load_balancer" {
  source = "./modules/load_balancer"

  name               = "LoadBalancerApplication${local.name_sufix}"
  load_balancer_type = "application"
  enable_http2       = "true"
  internal           = "false"
  security_groups    = [local.app_security_group_id]
  subnets            = local.exported_public_subnets
  idle_timeout       = "60"
}

module "create_target_group" {
  source      = "./modules/target_group"
  name        = "TargetGroupApplication${local.name_sufix}"
  port        = "80"
  protocol    = "HTTP"
  path        = "/index.php"
  target_type = "instance"
  target_id   = local.load_balancer_arn
  vpc_id      = local.vpc_id

}

module "create_auto_scaling_group" {
  source                    = "./modules/autoscaling"
  name                      = "AutoScalingGroup${local.name_sufix}"
  availability_zones        = ["${local.region}a", "${local.region}b"]
  default_instance_warmup   = "0"
  desired_capacity          = "2"
  max_size                  = "4"
  min_size                  = "1"
  force_delete              = "true"
  health_check_grace_period = "300"
  health_check_type         = "ELB"
  launch_template_id        = module.create_launch_template.launch_template_id
  launch_template_name      = module.create_launch_template.launch_template_name
  target_group_arn          = module.create_target_group.arn
  subnets                   = local.exported_private_subnets
}
