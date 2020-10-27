variable "username" {
  description = "MySQL Username"
  type        = string
}

variable "password" {
  description = "MySQL Password"
  type        = string
}

variable "host" {
  description = "MySQL Host"
  type        = string
}

variable "privileges" {
  description = "List of privileges for the user"
  type        = list(object({
    database = string
    grants   = list(string)
  }))
}

//variable "mysql_provider_endpoint" {
//  description = "Endpoint to set in the MySQL provider"
//  type        = string
//}
//
//variable "mysql_provider_username" {
//  description = "Username to set in the MySQL provider"
//  type        = string
//}
//
//variable "mysql_provider_password" {
//  description = "Password to set in the MySQL provider"
//  type        = string
//}
