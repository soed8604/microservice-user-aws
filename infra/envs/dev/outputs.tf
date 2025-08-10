output "alb_dns" { value = module.alb.alb_dns_name }
output "ecr_repo" { value = module.ecr.repository_url }
output "rds_endpoint" { value = module.rds.endpoint }
output "secrets_arn" { value = module.secrets.secret_arn }
