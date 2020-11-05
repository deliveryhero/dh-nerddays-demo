resource "aws_route53_zone" "internal-domain" {
  for_each = toset(var.route53_private_zones)
  name = each.key

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}
