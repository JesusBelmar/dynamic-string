# Generates a random ID to make the S3 bucket name globally unique
resource "random_id" "this" {
  byte_length = 8
}

# Creates the S3 bucket to store the dynamic string content
resource "aws_s3_bucket" "web" {
  bucket        = "dynamic-string-${random_id.this.hex}" # Unique bucket name
  force_destroy = true                                   # Only for dev; set false in production
}

# Enforce bucket ownership controls to make sure the bucket owner has full control
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.web.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access (recommended for CloudFront + OAI setup)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.web.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Attach a bucket policy allowing CloudFront OAI to access objects
resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.web.id
  policy = data.aws_iam_policy_document.cloudfront_s3.json
}
