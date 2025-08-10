resource "random_id" "secret_name" {
  byte_length = 4  # Ajusta la longitud según lo que necesites
}
resource "aws_secretsmanager_secret" "db" {
  name = "${var.name}-db-credentials-${random_id.secret_name.hex}"  # Agrega la cadena aleatoria al nombre

  description = "DB credentials stored in Secrets Manager"
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
