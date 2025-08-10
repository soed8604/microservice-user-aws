output "alb_arn"      { value = aws_lb.this.arn }
output "tg_arn"       { value = aws_lb_target_group.tg.arn }
output "alb_dns_name" { value = aws_lb.this.dns_name }
output "alb_sg_id" {
  description = "The Security Group ID of the Application Load Balancer"
  value       = aws_security_group.alb_sg.id
}