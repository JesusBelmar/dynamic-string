# Output the S3 bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.web.id
}

# Output the S3 bucket ARN
output "s3_bucket_arn" {
  value = aws_s3_bucket.web.arn
}

# Output the CloudFront distribution domain (useful for testing and accessing the site)
output "cloudfront_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

# Output the CloudFront distribution ID
output "cloudfront_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}
