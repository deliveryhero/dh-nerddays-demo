########################
# Keypair for Jumphost #
########################

module "jumphost-key-pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "jumphost"
  public_key = data.sops_file.secrets.data["jumphost.public-ssh-key"]
}

############################
# EC2 Instance as Jumphost #
############################
module "jumphost" {
  source = "git@github.com:deliveryhero/pd-tf-aws-jumphost?ref=v1.0.0"

  jumphost_instance_type = "t3.medium"
  ami_id                 = data.aws_ami.ubuntu-18-04.id
  vpc_id                 = module.vpc.vpc_id
  az_subnet = {
    eu-central-1a = data.aws_subnet.eu-central-1a.cidr_block // EBS and Instance must be in the same AZ
  }
  external_dns_zone_id        = data.aws_route53_zone.dh-nerddays-demo.id
  jumphost_keypair            = module.jumphost-key-pair.this_key_pair_key_name
  env                         = local.tags["Environment"]
  region                      = local.tags["Region"]
  monitoring                  = false
  associate_public_ip_address = true
  root_block_device = [
    {
      volume_size = "20" // in GB
      volume_type = "gp2"
    }
  ]
  dh_berlin_office_ips    = module.dh-ips.ipv4_cidr_blocks
  standard_os_users       = ["developer"]
  sudo_os_users           = ["infra"]
  packages_to_install     = ["mysql-client", "pv", "redis-tools", "python3", "python3-pip", "python3-dev", "libmysqlclient-dev", "python3-mysql.connector"]

  access_policies = [
    {
      name      = "as-infra-user"
      os_users  = ["infra"]
      sso_roles = [ for role in yamldecode(data.sops_file.secrets.raw).jumphost.users.infra.sso-roles : role ]
    }
  ]
}
