resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnets"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "Allow Postgres from ECS"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432
    security_groups = [var.ecs_service_sg_id] # permitir solo desde ECS
  }

  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier              = var.name
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  publicly_accessible     = false
  skip_final_snapshot     = true
}
