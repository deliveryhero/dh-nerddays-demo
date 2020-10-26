###################
# ACM (SSL certificate)
###################
module "wildcard_dh_nerddays_demo_com" {
  source  = "terraform-aws-modules/acm/aws"
  version = "v2.10.0"

  domain_name  = data.aws_route53_zone.dh-nerddays-demo.name
  zone_id      = data.aws_route53_zone.dh-nerddays-demo.id

  subject_alternative_names = [
    "*.${data.aws_route53_zone.dh-nerddays-demo.name}",
  ]

  tags = local.tags
}
