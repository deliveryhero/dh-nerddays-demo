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
  description = "List of privileges for the MySQL user"
  type        = list(object({
    database = string
    grants   = list(string)
  }))
}
