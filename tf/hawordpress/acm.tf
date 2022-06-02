module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name  = "ohavron-ocg1.link"
  zone_id      = "Z067633235P5TW5UJ6PXY"
}