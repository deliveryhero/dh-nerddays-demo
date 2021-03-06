#############
# RDS Aurora
#############
module "aurora_mysql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "v2.28.0"

  name                            = "aurora-demo-service-mysql"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.12"
  subnets                         = data.aws_subnet_ids.nerddays-demo-private.ids
  vpc_id                          = data.aws_vpc.nerddays-demo.id
  replica_count                   = 1
  instance_type                   = "db.t3.medium"
  apply_immediately               = true
  skip_final_snapshot             = true
  storage_encrypted               = true
  backup_retention_period         = 3
  db_parameter_group_name         = aws_db_parameter_group.aurora_mysql_57_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_mysql_57_cluster_parameter_group.id
  allowed_cidr_blocks             = [data.aws_vpc.nerddays-demo.cidr_block, data.aws_vpc.atlantis.cidr_block]

  username = data.sops_file.secrets.data["aurora-mysql.root-credentials.user"]
  password = data.sops_file.secrets.data["aurora-mysql.root-credentials.password"]

  create_security_group  = true
  create_monitoring_role = true

  tags                  = local.tags
  copy_tags_to_snapshot = true
}

resource "aws_db_parameter_group" "aurora_mysql_57_parameter_group" {
  name        = "aurora-demo-service-mysql-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "Demo Service - Aurora Parameter Group for Mysql 5.7"
}

resource "aws_rds_cluster_parameter_group" "aurora_mysql_57_cluster_parameter_group" {
  name        = "aurora-demo-service-mysql-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "Demo Service - Aurora Cluster Parameter Group for Mysql 5.7"
}

resource "aws_route53_record" "aurora_mysql_writer" {
  name = "aurora-mysql.writer"
  type = "CNAME"
  ttl  = "60"
  zone_id = data.aws_route53_zone.internal-dh-nerddays-demo.id
  records = [module.aurora_mysql.this_rds_cluster_endpoint]
}

resource "aws_route53_record" "aurora_mysql_reader" {
  name = "aurora-mysql.reader"
  type = "CNAME"
  ttl  = "60"
  zone_id = data.aws_route53_zone.internal-dh-nerddays-demo.id
  records = [module.aurora_mysql.this_rds_cluster_reader_endpoint]
}
