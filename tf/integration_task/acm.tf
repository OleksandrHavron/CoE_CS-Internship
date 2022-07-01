module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name  = var.domain_name
  zone_id      = var.domain_name_zone_id
}