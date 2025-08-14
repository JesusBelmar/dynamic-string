# IAM policy document to allow CloudFront's Origin Access Identity (OAI) 
# to read objects from the S3 bucket and list its contents.
data "aws_iam_policy_document" "cloudfront_s3" {

  # Statement 1: Allow CloudFront to GET objects from the bucket
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.web.arn}/*"] # All objects in the bucket

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn] # OAI ARN
    }

    # Restrict so only requests from this CloudFront distribution are allowed
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }

  # Statement 2: Allow CloudFront to list the bucket (needed for directory-style browsing or index.html)
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.web.arn] # Bucket itself

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn] # OAI ARN
    }

    # Restrict so only requests from this CloudFront distribution are allowed
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}
