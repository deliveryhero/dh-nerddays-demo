###############
# MySQL Users #
###############
resource "mysql_user" "demo_service" {
  provider           = "mysql.demo-service"
  user               = data.sops_file.secrets.data["aurora-mysql.users.demo-service.name"]
  plaintext_password = data.sops_file.secrets.data["aurora-mysql.users.demo-service.password"]
  host               = data.sops_file.secrets.data["aurora-mysql.users.demo-service.host"]
}

###################
# MySQL Databases #
###################
resource "mysql_database" "demo_service" {
  provider = "mysql.demo-service"
  name     = data.sops_file.secrets.data["aurora-mysql.databases.demo-service.name"]
}

resource "mysql_grant" "demo_service" {
  provider   = "mysql.demo-service"
  user       = mysql_user.demo_service.user
  host       = mysql_user.demo_service.host
  database   = mysql_database.demo_service.name
  privileges = [ for privilege in yamldecode(data.sops_file.secrets.raw).aurora-mysql.privileges.users.demo-service.databases.demo-service : privilege ]
}
