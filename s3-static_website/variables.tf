variable "aws_region" {
  description = "The region where the VPC will be created."
  type        = string
  default = "us-east-1"
}
 

variable "my_bucket_name" {
    description = "my bucket name"
    type = string
    default = "my-cloud9net-bucketv01"
}