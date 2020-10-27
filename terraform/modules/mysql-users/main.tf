###############
# MySQL Users #
###############
resource "mysql_user" "test_demo_service" {
  user               = var.username
  plaintext_password = var.password
  host               = var.host
}

####################
# MySQL Privileges #
####################
resource "mysql_grant" "test_demo_service" {
  for_each   = { for database in var.privileges : database.database => database }
  user       = var.username
  host       = var.host
  database   = each.key
  privileges = each.value.grants
}
