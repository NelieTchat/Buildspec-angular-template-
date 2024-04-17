output "s3_bucket_name" {
  description = "The name of the S3 bucket."
  value       = aws_s3_bucket.static_website.id
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint of the S3 bucket."
  value       = aws_s3_bucket.static_website.bucket_domain_name
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.my_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.my_distribution.id
}
