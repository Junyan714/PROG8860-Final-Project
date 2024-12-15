provider "aws" {
  region = "us-east-1"
}

# Generate a random ID for unique bucket name
resource "random_id" "bucket_id" {
  byte_length = 8
}

# Allow Public Access for S3 Bucket
resource "aws_s3_bucket_public_access_block" "react_bucket_access_block" {
  bucket                  = aws_s3_bucket.react_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket for React Frontend
resource "aws_s3_bucket" "react_bucket" {
  bucket        = "react-frontend-bucket-${random_id.bucket_id.hex}"
  acl           = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Name = "ReactFrontendBucket"
  }
}

# Bucket Policy to Allow Public Read
resource "aws_s3_bucket_policy" "react_bucket_policy" {
  bucket = aws_s3_bucket.react_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.react_bucket.arn}/*"
      }
    ]
  })
}

# Key Pair for EC2 Access
resource "aws_key_pair" "deployment_key" {
  key_name   = "flask-deployment-key"
  public_key = file("~/.ssh/id_rsa.pub") # Replace with your public key path
}

# Security Group for EC2
resource "aws_security_group" "flask_sg" {
  name        = "flask-backend-sg"
  description = "Allow HTTP and SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance for Flask Backend
resource "aws_instance" "flask_backend" {
  ami           = "ami-08c40ec9ead489470" # Amazon Linux 2 AMI (ensure this matches your region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployment_key.key_name
  security_groups = [aws_security_group.flask_sg.name]

  tags = {
    Name = "FlaskBackendServer"
  }

  user_data = <<-EOT
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable python3.8
              sudo yum install python3.8 -y
              sudo yum install git -y
              sudo yum install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              # Additional Flask setup commands go here
              EOT
}

# Outputs
output "s3_bucket_website_url" {
  description = "URL of the React frontend hosted on S3"
  value       = aws_s3_bucket.react_bucket.website_endpoint
}

output "flask_backend_public_ip" {
  description = "Public IP of the EC2 instance hosting Flask backend"
  value       = aws_instance.flask_backend.public_ip
}
