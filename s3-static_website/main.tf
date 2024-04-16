# Resource to create the S3 bucket with lifecycle management for preventing accidental deletion
resource "aws_s3_bucket" "static_website" {
  bucket = var.my_bucket_name # Name of the S3 bucket

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


resource "aws_s3_bucket_ownership_controls" "static_web" { # Sets up ownership controls for the specified S3 bucket
  bucket = aws_s3_bucket.static_website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

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
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.my_bucket_name}/*"
      }
    ]
  })
}

# Resource to configure website functionality
resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.static_website.id # ID of the S3 bucket

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

# Etag(entity Tag) defines a property of the aws_s3_object resource named "uploa_object"
# so it specifies teh Etag value for the uploaded file
# filemd5("html/${each.value}") : this function call that calculates the MD5 hash of the file being uploaded
# filemd5 : This is a string that combines the base path "html/" with the filename (each.value) retrieved from the fileset function iteration.