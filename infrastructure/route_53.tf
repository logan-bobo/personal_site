resource "aws_route53_record" "blog" {
    zone_id = var.dns_zone_id
    name    = var.domain
    type    = "A"

    alias {
        name                   = aws_cloudfront_distribution.s3_distribution.domain_name
        zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
        evaluate_target_health = true
    }
}