data "sops_file" "secrets" {
  source_file = "${path.module}/secrets.enc.yaml"
}

data "aws_availability_zones" "azs" {}

data "aws_route53_zone" "dh-nerddays-demo" {
  name         = "internal.dh-nerddays-demo.com"
  private_zone = true

  depends_on = [data.aws_vpc.nerddays-demo]
}

data "aws_vpc" "nerddays-demo" {
  tags = {
    Name = "nerddays-demo"
  }
}

data "aws_vpc" "atlantis" {
  tags = {
    Name = "atlantis"
  }
}

data "aws_subnet_ids" "nerddays-demo-private" {
  vpc_id = data.aws_vpc.nerddays-demo.id
  tags = {
    Visibility = "private"
  }

  depends_on = [data.aws_vpc.nerddays-demo]
}
