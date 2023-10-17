output "ecr_nginx" {
  value = aws_ecr_repository.nginx.repository_url
}

output "ecr_app" {
  value = aws_ecr_repository.app.repository_url
}

