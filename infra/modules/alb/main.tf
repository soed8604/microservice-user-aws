resource "aws_security_group" "alb_sg" {
  name   = "${var.name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"  # Aquí se agrega el tipo de target

  health_check {
    path    = "/health"
    interval            = 30         # Intervalo entre checks en segundos
    timeout             = 5          # Tiempo de espera para la respuesta en segundos
    healthy_threshold   = 3          # Número de respuestas 200 necesarias para marcar como healthy
    unhealthy_threshold = 3 
    matcher = "200"
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
  type             = "forward"
  target_group_arn = aws_lb_target_group.tg.arn
  }
}
