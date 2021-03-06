
resource "aws_acm_certificate" "blog" {
  provider                  = aws.acm_provider
  domain_name               = var.domain
  subject_alternative_names = ["www.${var.domain}"]
  validation_method         = "DNS"

  tags = var.global_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "dns_validation" {
  for_each = {
    for item in aws_acm_certificate.blog.domain_validation_options : item.domain_name => {
      name   = item.resource_record_name
      record = item.resource_record_value
      type   = item.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.dns_zone_id
}

resource "aws_acm_certificate_validation" "blog" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.blog.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_validation : record.fqdn]
}
