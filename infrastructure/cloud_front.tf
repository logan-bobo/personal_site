
locals {
    s3_origin_id = "S3Origin"
}

resource "aws_cloudfront_origin_access_identity" "blog" {
    comment = "custom OAI for S3 blog"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = aws_s3_bucket.blog.bucket_regional_domain_name
        origin_id   = local.s3_origin_id

        s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.blog.cloudfront_access_identity_path
        }
    }

    enabled             = true
    is_ipv6_enabled     = true
    default_root_object = "index.html"

    aliases = ["www.logan-cox.com", "logan-cox.com"]

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id

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
        restriction_type = "whitelist"
        locations        = ["US", "CA", "GB", "DE", "FR"]
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

