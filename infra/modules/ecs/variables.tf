variable "name"               { type = string }
variable "region"             { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "image"              { type = string }
variable "target_group_arn"   { type = string }
variable "secrets_arn"        { type = string } #  # ecr repo url + tag

variable "cpu" {
  type    = string
  default = "256"
}
variable "memory" {
  type    = string
  default = "512"
}
variable "desired_count" {
  type    = number
  default = 1
}
variable "db_ssl" {
  type    = bool
  default = false
}
variable "ecs_service_sg_id" {
  description = "Security group ID of the ECS service"
  type        = string
}