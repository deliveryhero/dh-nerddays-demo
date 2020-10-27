###############
# MySQL Users #
###############
resource "mysql_user" "demo_service" {
  provider           = mysql.demo-service
  user               = data.sops_file.secrets.data["aurora-mysql.users.demo-service.name"]
  plaintext_password = data.sops_file.secrets.data["aurora-mysql.users.demo-service.password"]
  host               = data.sops_file.secrets.data["aurora-mysql.users.demo-service.host"]
}

resource "mysql_user" "test_demo_service" {
  provider           = mysql.demo-service
  for_each           = [ for user in yamldecode(data.sops_file.secrets.raw).test.users : user ]
//  for_each           = data.sops_file.secrets.data["test.users"]
  user               = each.value.username
  plaintext_password = each.value.password
  host               = each.value.host
}

resource "mysql_grant" "demo_service" {
  provider   = mysql.demo-service
  user       = mysql_user.demo_service.user
  host       = mysql_user.demo_service.host
  database   = mysql_database.demo_service.name
  privileges = [ for privilege in yamldecode(data.sops_file.secrets.raw).aurora-mysql.privileges.users.demo-service.databases.demo-service : privilege ]
}

resource "mysql_grant" "test_demo_service" {
  provider   = mysql.demo-service
  for_each   = [ for user in yamldecode(data.sops_file.secrets.raw).test.users : user ]
//  for_each   = data.sops_file.secrets.data["test.users"]
  user       = each.value.username
  host       = each.value.host
  database   = each.value.privileges.database
  privileges = [ for privilege in each.value.privileges.grants : privilege ]
}

###################
# MySQL Databases #
###################
resource "mysql_database" "demo_service" {
  provider = mysql.demo-service
  name     = data.sops_file.secrets.data["aurora-mysql.databases.demo-service.name"]
}

resource "mysql_database" "test_demo_service" {
  provider = mysql.demo-service
  for_each = [ for database in yamldecode(data.sops_file.secrets.raw).test.databases : database ]
//  for_each = [ for database in data.sops_file.secrets.data["test.databases"] : database ]
  name     = each.value
}
