

resource "aws_cloudfront_distribution" "blog" {
  origin {
    domain_name = aws_s3_bucket.blog.website_endpoint
    origin_id   = "S3-${var.blog_bucket_name}"

    custom_origin_config {
      http_port = 80
      # Required but not used
      https_port = 443
      # The origin endpoint HTTP only hence why we are using cloud front to serve traffic over SSL/TLS
      origin_protocol_policy = "http-only"
      # Required but not used
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["www.logan-cox.com", "logan-cox.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.blog_bucket_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = var.global_tags

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.blog.arn
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }
}

