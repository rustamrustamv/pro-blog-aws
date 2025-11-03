# outputs.tf

output "server_public_ip" {
  description = "The public IP address of our EC2 instance"
  value       = aws_instance.blog_server.public_ip
}

output "db_endpoint" {
  description = "The connection endpoint for the RDS database"
  value       = aws_db_instance.blog_db.endpoint
}