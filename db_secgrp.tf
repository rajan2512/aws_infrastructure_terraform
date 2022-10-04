locals {

  vpc_id                = module.vpc_ig.vpc_id
  db_subnet_ids         = [local.exported_db_subnets[0].subnet.id, local.exported_db_subnets[1].subnet.id]
  efs_security_group_id = module.RDSSecurityGroup.ids_map["EFSMountTargetSecurityGroup${local.name_sufix}"].id
  app_security_group_id = module.RDSSecurityGroup.ids_map["WebAppInstanceSecurityGroup${local.name_sufix}"].id
  rds_security_group_id = module.RDSSecurityGroup.ids_map["RDSSecurityGroup${local.name_sufix}"].id
}
module "subnet_group" {
  source     = "./modules/db_subnet_group"
  subnet_ids = local.db_subnet_ids
  tags       = {}
}

module "RDSSecurityGroup" {
  source = "./modules/security_group"
  security_group_sets = {
    "WebAppInstanceSecurityGroup${local.name_sufix}" = {
      vpc_id = local.vpc_id

      ingress = [
        {
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = "443"
          protocol    = "tcp"
          self        = "false"
          to_port     = "443"
        },
        {
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = "80"
          protocol    = "tcp"
          self        = "false"
          to_port     = "80"
        }
      ]

      egress = [
        {
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = "0"
          protocol    = "-1"
          self        = "false"
          to_port     = "0"
      }]
    },

    "RDSSecurityGroup${local.name_sufix}" = {
      vpc_id = local.vpc_id

      ingress = [
        {
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = "3306"
          protocol    = "tcp"
          self        = "false"
          to_port     = "3306"
      }]

      egress = [{
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = "0"
        protocol    = "-1"
        self        = "false"
        to_port     = "0"

      }]
    },
    "EFSMountTargetSecurityGroup${local.name_sufix}" = {
      vpc_id = local.vpc_id

      ingress = [
        {
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = "2049"
          protocol    = "tcp"
          self        = "false"
          to_port     = "2049"
        },
      ]

      egress = [
        {
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = "0"
          protocol    = "-1"
          self        = "false"
          to_port     = "0"
        }
      ]
    },
  }
}

resource "aws_security_group_rule" "example" {
  depends_on = [
    module.RDSSecurityGroup
  ]
  type                     = "ingress"
  security_group_id        = local.efs_security_group_id
  from_port                = "80"
  protocol                 = "tcp"
  source_security_group_id = local.app_security_group_id
  to_port                  = "80"
}

 module "db_instance_main" {
  count                      = local.failover ? 0 : 1
  source                     = "./modules/db_instance"
  depends_on                 = [module.subnet_group, module.RDSSecurityGroup]
  allocated_storage          = "20"
  auto_minor_version_upgrade = "true"
  backup_retention_period    = "7"
  backup_window              = "23:53-00:23"
  copy_tags_to_snapshot      = "true"
  maintenance_window         = "sun:01:29-sun:01:59"
  db_subnet_group_name       = module.subnet_group.id
  multi_az                   = "false"
  storage_encrypted          = "true"
  publicly_accessible        = "false"
  storage_type               = "gp2"
  engine                     = "mysql"
  engine_version             = "8.0.28"
  instance_class             = "db.t3.micro"
  name                       = "appdb"
  username                   = "admin"
  password                   = "adminadmin"
  parameter_group_name       = "default.mysql8.0"
  skip_final_snapshot        = "true"
  vpc_security_group_ids     = [local.rds_security_group_id]
  tags                       = {}
 }

module "db_instance_replica" {
  count = local.failover ? 0 : 1
  depends_on = [
    module.db_instance_main
  ]
  source                     = "./modules/db_instance"
  allocated_storage          = "20"
  auto_minor_version_upgrade = "true"
  backup_retention_period    = "7"
  backup_window              = "23:53-00:23"
  copy_tags_to_snapshot      = "true"
  maintenance_window         = "sun:01:29-sun:01:59"
  db_subnet_group_name       = ""
  multi_az                   = "false"
  storage_encrypted          = "true"
  publicly_accessible        = "false"
  storage_type               = "gp2"
  instance_class             = "db.t3.micro"
  parameter_group_name       = "default.mysql8.0"
  vpc_security_group_ids     = [local.rds_security_group_id]
  replicate_source_db        = module.db_instance_main[0].arn
  skip_final_snapshot        = "true"
  tags                       = {}
 }
