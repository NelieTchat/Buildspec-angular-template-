# Define variables
variable "aws_region" {
  description = "The region where the resources will be created."
  type        = string
  # default     = "us-east-1"
}

variable "my_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  # default     = "my-cicd-static-cloud9net-project"
}

variable "cloudfront_origin_domain_name" {
  description = "The domain name of the S3 bucket website endpoint."
  type        = string
}

variable "cloudfront_origin_id" {
  description = "The unique identifier for the CloudFront origin."
  type        = string
}

variable "cloudfront_default_root_object" {
  description = "The default root object for the CloudFront distribution."
  type        = string
}

variable "cloudfront_comment" {
  description = "A comment for the CloudFront distribution."
  type        = string
}

variable "cloudfront_allowed_methods" {
  description = "The allowed HTTP methods for the CloudFront distribution."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cloudfront_cached_methods" {
  description = "The cached HTTP methods for the CloudFront distribution."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cloudfront_forwarded_cookies" {
  description = "The behavior for forwarded cookies in the CloudFront distribution."
  type        = string
  default     = "none"
}

variable "cloudfront_min_ttl" {
  description = "The minimum TTL (time to live) for objects in the CloudFront cache."
  type        = number
  default     = 0
}

variable "cloudfront_default_ttl" {
  description = "The default TTL (time to live) for objects in the CloudFront cache."
  type        = number
  default     = 3600
}

variable "cloudfront_max_ttl" {
  description = "The maximum TTL (time to live) for objects in the CloudFront cache."
  type        = number
  default     = 86400
}

variable "cloudfront_restriction_type" {
  description = "The type of geo-restriction for the CloudFront distribution."
  type        = string
  default     = "none"
}

variable "cloudfront_viewer_certificate" {
  description = "The viewer certificate configuration for the CloudFront distribution."
  type        = object({
    cloudfront_default_certificate = bool
  })
  default = {
    cloudfront_default_certificate = true
  }
}
