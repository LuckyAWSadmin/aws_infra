terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-netlink"   # Change name (must be globally unique)
    key            = "aws_infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"           # Optional for state locking
  }
}

provider "aws" {
  region = "ap-south-1"
}

# S3 bucket for hosting website
resource "aws_s3_bucket" "netlink_site" {
  bucket = "netlink-cctv-site"   # Change (must be globally unique)
}

resource "aws_s3_bucket_website_configuration" "netlink_site" {
  bucket = aws_s3_bucket.netlink_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Public access policy
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.netlink_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.netlink_site.arn}/*"
      }
    ]
  })
}

# Block public access (disabled so website works)
resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket                  = aws_s3_bucket.netlink_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
