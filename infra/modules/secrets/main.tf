resource "aws_secretsmanager_secret" "db" {
  name = "${var.name}-db-credentials-example"
}

resource "aws_secretsmanager_secret_version" "db_v" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    database = var.db_name
    host     = var.db_host   # si usas RDS endpoint lo setearás después (o update)
    port     = var.db_port
    ssl      = var.db_ssl
  })
}
