locals {
  mysql_provider = {
    endpoint = format("%s:3306", module.aurora_mysql.this_rds_cluster_endpoint)
    username = data.sops_file.secrets.data["aurora-mysql.root-credentials.user"]
    password = data.sops_file.secrets.data["aurora-mysql.root-credentials.password"]
  }

  tags = {
    Environment = "demo"
    Region      = "eu"
    Service     = "demo-service"
  }
}
