
resource "aws_efs_file_system" "main" {
  count     = var.failover ? 0 : 1
  encrypted = var.encrypted

  tags = {
    Name = var.name
  }
}
resource "aws_efs_replication_configuration" "replica" {
  count                 = var.failover ? 0 : 1
  source_file_system_id = aws_efs_file_system.main[0].id


  destination {
    region = "us-east-1"
  }
  provisioner "local-exec" {
    command = "aws efs create-tags --region us-east-1 --file-system-id ${self.destination[0].file_system_id} --tags Key=Name,Value=failover Key=Id,Value=${self.destination[0].file_system_id}"
  }
}
data "aws_efs_file_system" "replica" {
  count = var.failover ? 1 : 0

  tags = {
    Name = "failover"
  }
}





resource "aws_efs_mount_target" "main" {
  for_each        = { for id, subnet in var.private_subnets : id => subnet }
  file_system_id  = var.failover ? data.aws_efs_file_system.replica[0].id : aws_efs_file_system.main[0].id
  subnet_id       = each.value.subnet.id
  security_groups = var.security_groups
}
