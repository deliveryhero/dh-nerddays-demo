#######
# VPC #
#######
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.47.0"

  name                 = local.atlantis_vpc_name
  cidr                 = "10.50.0.0/16"
  azs                  = data.aws_availability_zones.azs.names
  private_subnets      = [for index, az in data.aws_availability_zones.azs.names : cidrsubnet("10.50.0.0/16", 8, (index + 1))]
  public_subnets       = [for index, az in data.aws_availability_zones.azs.names : cidrsubnet("10.50.0.0/16", 8, (index + 101))]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Visibility                                        = "public"
    Usage                                             = "atlantis"
    VPC                                               = local.atlantis_vpc_name
  }

  private_subnet_tags = {
    Visibility                                        = "private"
    Usage                                             = "atlantis"
    VPC                                               = local.atlantis_vpc_name
  }

  tags = local.tags
}
