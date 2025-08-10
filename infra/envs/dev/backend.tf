# Configuración para guardar el estado de Terraform de forma remota
terraform {
  backend "s3" {
    # Reemplaza con el nombre del bucket que creaste
    bucket         = "tf-jelou"
    key            = "dev/mi-microservicio.tfstate" # Ruta del estado para este entorno
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table" # La tabla que creaste
    encrypt        = true
  }
}