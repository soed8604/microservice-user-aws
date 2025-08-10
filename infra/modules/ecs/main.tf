resource "aws_iam_role" "task_exec" {
  name = "${var.name}-task-exec"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}

data "aws_iam_policy_document" "task_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy_attachment" "exec_ecr" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Permiso para leer secrets
resource "aws_iam_role_policy" "secrets" {
  name = "${var.name}-secrets"
  role = aws_iam_role.task_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = [var.secrets_arn]
    }]
  })
}

resource "aws_ecs_cluster" "this" {
  name = var.name
}

resource "aws_security_group" "service_sg" {
  name   = "${var.name}-svc-sg"
  vpc_id = var.vpc_id

      # Regla de tráfico entrante desde el Load Balancer en el puerto 3000 (puerto de la aplicación)
  ingress {
    protocol        = "tcp"
    from_port       = 3000   # Puerto de la aplicación
    to_port         = 3000
    security_groups = [var.ecs_service_sg_id]  # Solo permitir tráfico del Security Group del ALB
  }
  # tráfico saliente a RDS/Internet
    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.task_exec.arn

  container_definitions = jsonencode([
    {
      name      = "app",
      image     = var.image,
      essential = true,
      portMappings = [{ containerPort = 3000, hostPort = 3000, protocol = "tcp" }],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/${var.name}",
          awslogs-region        = var.region,
          awslogs-stream-prefix = "app"
        }
      },
      environment = [
        { name = "DB_SSL", value = tostring(var.db_ssl) }
      ],
      secrets = [
        { name = "DB_USER",      valueFrom = "${var.secrets_arn}:username::" },
        { name = "DB_PASSWORD",  valueFrom = "${var.secrets_arn}:password::" },
        { name = "DB_DATABASE",  valueFrom = "${var.secrets_arn}:database::" },
        { name = "DB_HOST",      valueFrom = "${var.secrets_arn}:host::" },
        { name = "DB_PORT",      valueFrom = "${var.secrets_arn}:port::" }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_cloudwatch_log_group" "lg" {
  name              = "/ecs/${var.name}"
  retention_in_days = 14
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = 3000
  }

}
