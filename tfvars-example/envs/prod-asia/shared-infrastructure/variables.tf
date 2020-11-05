#######
# VPC #
#######
variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "vpc_private_subnets" {
  description = "List of private subnets to create"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "List of public subnets to create"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Whether to enable NAT Gateway or not"
  type        = bool
}

variable "vpc_single_nat_gateway" {
  description = "Whether to have a single NAT Gateway or not - Requires `vpc_enable_nat_gateway:true`"
  type        = bool
}

variable "vpc_enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames in the VPC or not"
  type        = bool
}

variable "vpc_enable_dns_support" {
  description = "Whether to enable DNS support in the VPC or not"
  type        = bool
}

variable "vpc_public_subnet_tags" {
  description = "Map of tags to add to the public subnets"
  type        = map(any)
}

variable "vpc_private_subnet_tags" {
  description = "Map of tags to add to the private subnets"
  type        = map(any)
}

variable "vpc_tags" {
  description = "Map of tags to add to the VPC"
  type        = map(any)
}

#######
# EKS #
#######
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "eks_enable_irsa" {
  description = "Whether to enable IRSA for the EKS cluster or not"
  type        = bool
}

variable "eks_tags" {
  description = "Map of Tags to add to the EKS cluster"
  type        = map(any)
}

variable "eks_node_groups_defaults" {
  description = "Default values for Node Groups"
  type        = any
}

variable "eks_node_groups" {
  description = "List of Managed Workers to add"
  type        = any
}

variable "eks_map_roles" {
  description = "List of Roles to Map to the EKS cluster"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

###########
# Route53 #
###########
variable "route53_private_zones" {
  description = "List of Route53 private zones to create"
  type        = list(string)
  default     = []
}
