# Creates an Origin Access Identity (OAI) so CloudFront can securely access the S3 bucket.
# This ensures the bucket can remain private and only be accessed via CloudFront.
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for dynamic-string bucket"
}

# Creates the CloudFront distribution to serve content from the S3 bucket.
resource "aws_cloudfront_distribution" "this" {
  enabled             = true         # Enables the distribution
  default_root_object = "index.html" # Default file served if no object is specified
  comment             = "Dynamic String CDN"

  # Origin configuration (S3 bucket as the origin)
  origin {
    domain_name = aws_s3_bucket.web.bucket_regional_domain_name # The S3 bucket regional domain
    origin_id   = "s3-origin"                                   # Unique identifier for this origin

    s3_origin_config {
      # Link the OAI so CloudFront has access to private bucket content
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  # Default cache behavior configuration
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"] # Only read operations are allowed
    cached_methods   = ["GET", "HEAD"] # Only cache GET and HEAD requests
    target_origin_id = "s3-origin"     # Points to the defined S3 origin
    compress         = true            # Enable GZIP/Brotli compression for better performance

    forwarded_values {
      query_string = false # No query strings forwarded (improves caching efficiency)
      cookies {
        forward = "none" # Do not forward cookies to origin
      }
    }

    viewer_protocol_policy = "redirect-to-https" # Force HTTPS access
    min_ttl                = 0                   # Minimum TTL (in seconds)
    default_ttl            = 0                   # Default TTL (in seconds)
    max_ttl                = 0                   # Max TTL (in seconds)

  }

  # No geo restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Use the default CloudFront SSL certificate (*.cloudfront.net)
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
