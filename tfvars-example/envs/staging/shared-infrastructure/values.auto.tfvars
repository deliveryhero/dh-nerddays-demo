##############
# VPC Values #
##############
vpc_name = "staging"
vpc_cidr = "10.10.0.0/16"
vpc_private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
vpc_public_subnets  = ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]
vpc_enable_nat_gateway = true
vpc_single_nat_gateway = true
vpc_enable_dns_hostnames = true
vpc_enable_dns_support = true

vpc_public_subnet_tags = {
  Visibility                              = "public"
  "kubernetes.io/cluster/staging-cluster" = "shared"
  "kubernetes.io/role/elb"                = "true"
}
vpc_private_subnet_tags = {
  Visibility                              = "private"
  "kubernetes.io/cluster/staging-cluster" = "shared"
  "kubernetes.io/role/internal-elb"       = "true"
}

vpc_tags = {
  Environment = "staging"
  Region      = "eu"
}

##############
# EKS Values #
##############
eks_cluster_name = "staging-cluster"
eks_cluster_version = "1.17"
eks_enable_irsa = true
eks_tags = {
  Kubernetes = true
  Environment = "staging"
  Region      = "eu"
}
eks_node_groups_defaults = {
  ami_type  = "AL2_x86_64"
  disk_size = 50
}
eks_node_groups = {
  workers-1 = {
      name             = "staging-cluster-workers-1"
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "t3.medium"
      k8s_labels = {
        environment     = "staging"
        managed-worker  = "true"
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"               = "true"
        "k8s.io/cluster-autoscaler/staging-cluster" = "owned"
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
route53_private_zones = ["internal.staging-domain.com"]
