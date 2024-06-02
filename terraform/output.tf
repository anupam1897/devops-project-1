output "isntance_public_ip" {
  value = aws_instance.server.public_ip
  sensitive = true
}
