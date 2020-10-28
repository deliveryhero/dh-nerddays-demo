###############
# MySQL Users #
###############
resource "mysql_user" "user" {
  user               = var.username
  plaintext_password = var.password
  host               = var.host
}

####################
# MySQL Privileges #
####################
resource "mysql_grant" "grants" {
  for_each   = { for privilege in var.privileges: privilege.database => privilege }
  user       = var.username
  host       = var.host
  database   = each.key
  privileges = each.value.grants

  depends_on = [mysql_user.user]
}
