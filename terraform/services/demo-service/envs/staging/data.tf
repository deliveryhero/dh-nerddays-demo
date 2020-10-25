data "aws_availability_zones" "azs" {}

data "aws_route53_zone" "dh-nerddays-demo" {
  name = "dh-nerddays-demo.com"
}

data "aws_vpc" "nerddays-demo" {
  tags = {
    Name = "nerddays-demo"
  }
}

data "aws_subnet_ids" "nerddays-demo-private" {
  vpc_id = data.aws_vpc.nerddays-demo.id
  tags   = {
    Visibility = "private"
  }

  depends_on = [data.aws_vpc]
}
