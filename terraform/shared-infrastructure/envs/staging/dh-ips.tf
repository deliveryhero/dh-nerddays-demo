##########
# DH IPs #
##########
module "dh-ips" {
  source = "git::ssh://git@github.com/deliveryhero/dh-gcs-terraform-tools.git//ip-whitelist-module"
  token  = data.sops_file.secrets.data["dh-ips.token"]
}
