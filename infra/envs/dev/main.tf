module "vpc" {
  source          = "../../modules/vpc"
  name            = var.name
  cidr            = var.cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "ecr" {
  source = "../../modules/ecr"
  name   = "${var.name}-repo"
}

# Secret inicial (host temporal vacío; lo actualizaremos luego con el endpoint RDS)
module "secrets" {
  source      = "../../modules/secrets"
  name        = var.name
  db_username = var.db_username
  db_password = var.db_password
  db_name     = var.db_name
  db_host     = "" # se actualizará luego
  db_port     = 5432
  db_ssl      = var.db_ssl
}

# ALB
module "alb" {
  source            = "../../modules/alb"
  name              = var.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

# ECS (se necesita el tg para el service)
module "ecs" {
  source             = "../../modules/ecs"
  name               = var.name
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  ecs_service_sg_id  = module.alb.alb_sg_id
  private_subnet_ids = module.vpc.private_subnet_ids
  image              = "${module.ecr.repository_url}:${var.image_tag}"
  secrets_arn        = module.secrets.secret_arn
  db_ssl             = var.db_ssl
  target_group_arn   = module.alb.tg_arn
  cpu                = var.cpu
  memory             = var.memory

  depends_on = [module.alb]
}

# RDS (necesita SG de ECS para permitir tráfico)
module "rds" {
  source             = "../../modules/rds"
  name               = var.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_service_sg_id  = module.ecs.service_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}

# Una vez creado RDS, actualiza secret con host:
resource "aws_secretsmanager_secret_version" "db_update" {
  secret_id = module.secrets.secret_arn
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    database = var.db_name
    host     = module.rds.endpoint
    port     = 5432
    ssl      = var.db_ssl
  })
}
