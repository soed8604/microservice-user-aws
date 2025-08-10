variable "region" { type = string }
variable "name" { type = string } # prefijo del stack, p.ej. "users-dev"
variable "azs" { type = list(string) }
variable "cidr" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "image" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "image_tag" { type = string }
variable "db_ssl" {
  type    = bool
  default = false
}
variable "cpu" {
  type    = string
  default = "256"
}
variable "memory" {
  type    = string
  default = "512"
}