module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.2.0"
  cluster_name    = local.eks_cluster_name
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets

  tags = merge(local.tags,
         {
           Kubernetes = true
         })

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    workers-1 = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "t3.medium"
      k8s_labels = {
        environment     = "demo"
        managed-worker  = "true"
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/${local.eks_cluster_name}" = "owned"
      }
    }
  }

  map_roles    = [
    {
      rolearn  = data.sops_file.secrets.data["eks-roles.infra.role"]
      username = data.sops_file.secrets.data["eks-roles.infra.username"]
      groups   = [for group in yamldecode(data.sops_file.secrets.raw).eks-roles.infra.groups : group ]
    }
  ]
}
