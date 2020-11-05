##############
# VPC Values #
##############
vpc_name                 = "prod-asia"
vpc_cidr                 = "10.100.0.0/16"
vpc_private_subnets      = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
vpc_public_subnets       = ["10.100.4.0/24", "10.100.5.0/24", "10.100.6.0/24"]
vpc_enable_nat_gateway   = true
vpc_single_nat_gateway   = true
vpc_enable_dns_hostnames = true
vpc_enable_dns_support   = true

vpc_public_subnet_tags = {
  Visibility                                = "public"
  "kubernetes.io/cluster/prod-asia-cluster" = "shared"
  "kubernetes.io/role/elb"                  = "true"
}
vpc_private_subnet_tags = {
  Visibility                                = "private"
  "kubernetes.io/cluster/prod-asia-cluster" = "shared"
  "kubernetes.io/role/internal-elb"         = "true"
}

vpc_tags = {
  Environment = "production"
  Region      = "asia"
}

##############
# EKS Values #
##############
eks_cluster_name    = "prod-asia-cluster"
eks_cluster_version = "1.17"
eks_enable_irsa     = true
eks_tags = {
  Kubernetes  = true
  Environment = "production"
  Region      = "asia"
}
eks_node_groups_defaults = {
  ami_type  = "AL2_x86_64"
  disk_size = 50
}
eks_node_groups = {
  workers-1 = {
    name             = "prod-asia-cluster-workers-1"
    desired_capacity = 1
    max_capacity     = 10
    min_capacity     = 1

    instance_type = "t3.medium"
    k8s_labels = {
      environment    = "production"
      managed-worker = "true"
    }
    additional_tags = {
      "k8s.io/cluster-autoscaler/enabled"           = "true"
      "k8s.io/cluster-autoscaler/prod-asia-cluster" = "owned"
    }
  }
}
eks_map_roles = [
  {
    rolearn  = "arn:aws:iam::012345678901:role/administrator"
    username = "user:{{SessionName}}"
    groups   = ["system:admin"]
  }
]

##################
# Route53 Values #
##################
route53_private_zones = ["internal.prod-asia-domain.com"]
