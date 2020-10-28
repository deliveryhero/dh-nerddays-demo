###################
# MySQL Databases #
###################
resource "mysql_database" "aurora_mysql" {
  for_each = toset(local.mysql_secrets.aurora-mysql.databases)
  name     = each.value
}

########################
# MySQL Users & Grants #
########################
module "mysql_users_for_aurora_mysql" {
  source = "../../modules/mysql-users"
  providers = {
    mysql = mysql
  }
  for_each = { for user in local.mysql_secrets.aurora-mysql.users : user.username => user }

  username   = each.key
  password   = each.value.password
  host       = each.value.host
  privileges = each.value.privileges
}
