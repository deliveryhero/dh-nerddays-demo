#########
# REDIS #
#########
//module "redis" {
//  source                     = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=0.25.0"
//  availability_zones         = data.aws_availability_zones.azs.names
//  name                       = "demo-service"
//  dns_subdomain              = "demo-service.redis"
//  zone_id                    = data.aws_route53_zone.internal-dh-nerddays-demo.id
//  vpc_id                     = data.aws_vpc.nerddays-demo.id
//  allowed_cidr_blocks        = [data.aws_vpc.nerddays-demo.cidr_block]
//  subnets                    = data.aws_subnet_ids.nerddays-demo-private.ids
//  cluster_size               = 1
//  instance_type              = "cache.t3.micro"
//  apply_immediately          = true
//  automatic_failover_enabled = false
//  engine_version             = "4.0.10"
//  family                     = "redis4.0"
//  at_rest_encryption_enabled = true
//}
