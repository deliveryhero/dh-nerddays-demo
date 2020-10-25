resource "aws_route53_zone" "internal-domain" {
  name = "internal.dh-nerddays-demo.com"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}
