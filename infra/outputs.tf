output "frontend_url" {
  description = "URL of the React frontend hosted on S3"
  value       = aws_s3_bucket.react_bucket.website_endpoint
}

output "backend_public_ip" {
  description = "Public IP of the EC2 instance hosting Flask backend"
  value       = aws_instance.flask_backend.public_ip
}
