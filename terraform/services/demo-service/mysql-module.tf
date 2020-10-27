resource "mysql_database" "test_demo_service" {
  provider = mysql.demo-service
  for_each = toset(yamldecode(data.sops_file.secrets.raw).test.databases)
//  for_each = [ for database in data.sops_file.secrets.data["test.databases"] : database ]
  name     = each.value
}

module "mysql_user" {
  source   = "../../modules/mysql-users"
  for_each = { for user in yamldecode(data.sops_file.secrets.raw).test.users : user.username => user }

  username     = each.key
  password     = each.value.password
  host         = each.value.host
  privileges   = [
    {
      database = { for database in each.value.privileges : database.database => database }
      grants   = { for grants in each.value.privileges : grants.grants => grants }
    }
  ]
}
