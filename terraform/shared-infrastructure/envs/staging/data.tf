data "aws_availability_zones" "azs" {}

data "sops_file" "secrets" {
  source_file = "${path.module}/secrets.enc.yaml"
}

data "aws_subnet" "eu-central-1a" {
  availability_zone = "eu-central-1a"
  vpc_id            = module.vpc.vpc_id
  tags = {
    Visibility = "public"
  }
  depends_on = [ module.vpc ]
}

data "aws_ami" "ubuntu-18-04" {
  owners = ["099720109477"]
  name_regex = "^ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20201014$"
}

data "aws_route53_zone" "dh-nerddays-demo" {
  name = "dh-nerddays-demo.com"
}
