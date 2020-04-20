output "service_url" {
  value = "http://${aws_alb.main.dns_name}"
}