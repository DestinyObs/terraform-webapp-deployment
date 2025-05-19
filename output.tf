output "load_balancer_dns" {
  description = "DNS of the Load Balancer"
  value       = aws_lb.webapp_lb.dns_name
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.webapp_instance.public_ip
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.webapp_instance.id
}

output "target_group_arn" {
  description = "ARN of the Load Balancer Target Group"
  value       = aws_lb_target_group.webapp_tg.arn
}

output "security_group_id" {
  description = "Security Group ID attached to the instance and LB"
  value       = aws_security_group.web_sg.id
}

output "key_pair_name" {
  description = "Name of the SSH Key Pair"
  value       = aws_key_pair.webapp_key.key_name
}
