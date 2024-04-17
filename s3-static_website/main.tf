# Resource to create the S3 bucket with lifecycle management for preventing accidental deletion
resource "aws_s3_bucket" "static_website" {
   bucket = var.my_bucket_name# Name of the S3 bucket

  lifecycle { # Prevent accidental deletion of the S3 bucket.
    prevent_destroy = false
  }
}

# Separate resource for bucket versioning
resource "aws_s3_bucket_versioning" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  versioning_configuration {
    status = "Enabled"  # Enable versioning for the bucket
  }
}

# Separate resource for server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Sets up ownership controls for the specified S3 bucket
resource "aws_s3_bucket_ownership_controls" "static_web" { 
  bucket = aws_s3_bucket.static_website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Enable public access
resource "aws_s3_bucket_public_access_block" "static_web" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# AWS S3 bucket ACL resource
resource "aws_s3_bucket_acl" "static_web" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_web,
    aws_s3_bucket_public_access_block.static_web,
  ]

  bucket = aws_s3_bucket.static_website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "host_bucket_policy" {
  bucket = aws_s3_bucket.static_website.id # ID of the S3 bucket

  # Policy JSON for allowing public read access
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject"
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.my_bucket_name}/*"
      }
    ]
  })
}

# Resource to enable static website hosting
resource "aws_s3_bucket_website_configuration" "web-config" {  # Update resource type
  bucket = aws_s3_bucket.static_website.id

  # Configuration for the index document
  index_document {
    suffix = "index.html"
  }

  # Configuration for the error document (optional)
  error_document {
    key = "error.html"  # Specify the key (object name) of the error document
  }
}

##### will upload all the files present under HTML folder to the S3 bucket #####
resource "aws_s3_object" "upload_object" {
  for_each      = fileset("html/", "*") # iterates ovel all the files within "html/" directory. fileset is the function that retrieves a list of all files from the specified path
  bucket        = aws_s3_bucket.static_website.id
  key           = each.value #each.value refers to the filename retrieved from the fileset function
  source        = "html/${each.value}" # specifies the source location of the file to be uploaded
  etag          = filemd5("html/${each.value}")
  content_type  = "text/html" #sets the content type to text that will help browsers correctly interpret the files HTML 
}

# Etag(entity Tag) defines a property of the aws_s3_object resource named "upload_object"
# so it specifies the Etag value for the uploaded file
# filemd5("html/${each.value}") : this function call that calculates the MD5 hash of the file being uploaded
# filemd5 : This is a string that combines the base path "html/" with the filename (each.value) retrieved from the fileset function iteration.

# Create Cloudfront Distribution Resource for the Static-Website
resource "aws_cloudfront_distribution" "my_distribution" {
  depends_on = [aws_s3_bucket.static_website]

  origin {
    domain_name = var.cloudfront_origin_domain_name
    origin_id   = var.cloudfront_origin_id
    
    # By default CloudFront might not know which ports on your s3 bucket to use for communication
    # Thia missing piece explicitly tells CloudFront which ports to connect on the s3 bucket origin
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cloudfront_comment
  default_root_object = var.cloudfront_default_root_object

  default_cache_behavior {
    allowed_methods  = var.cloudfront_allowed_methods
    cached_methods   = var.cloudfront_cached_methods
    target_origin_id = var.cloudfront_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = var.cloudfront_forwarded_cookies
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.cloudfront_min_ttl
    default_ttl            = var.cloudfront_default_ttl
    max_ttl                = var.cloudfront_max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_restriction_type
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_viewer_certificate.cloudfront_default_certificate
  }
}
