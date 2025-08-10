variable "name"               { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ecs_service_sg_id"  { type = string }
variable "engine_version" {
  type    = string
  default = "16.9"
}
variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "allocated_storage"  { 
    type = number   
    default = 20 
}
variable "db_name"            { type = string }
variable "db_username"        { type = string }
variable "db_password"        { type = string }
