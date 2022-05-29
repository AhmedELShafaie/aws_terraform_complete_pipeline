output "server-dns" {
  value = aws_instance.web.public_dns
}

output "server-address" {
  value = aws_instance.web.public_ip
}

