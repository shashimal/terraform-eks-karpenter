module "acm" {
  source                    = "terraform-aws-modules/acm/aws"
  version                   = "~> 4.0"
  domain_name               = "sms.duleendra.com"
  zone_id                   = aws_route53_zone.sms.zone_id
  subject_alternative_names = []

  wait_for_validation = false
  tags = {
    Name = local.app_name
  }
}


resource "aws_route53_zone" "sms" {
  name = "sms.duleendra.com"

  tags = {
    Name = local.app_name
  }
}


resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in module.acm.acm_certificate_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.sms.zone_id
}
