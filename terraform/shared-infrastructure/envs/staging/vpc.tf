module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.47.0"

  name                 = "nerddays-demo"
  cidr                 = "10.100.0.0/16"
  azs                  = data.aws_availability_zones.azs.names
  private_subnets      = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  public_subnets       = ["10.100.4.0/24", "10.100.5.0/24", "10.100.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                          = "true"
    Visibility                                        = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = "true"
    Visibility                                        = "private"
  }

  tags = local.tags
}
