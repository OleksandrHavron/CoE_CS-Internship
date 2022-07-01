data "aws_route53_zone" "hawordpress" {
  name = "ohavron-ocg1.link"
}

resource "aws_route53_record" "hawordpress" {
  zone_id = data.aws_route53_zone.hawordpress.zone_id
  name    = data.aws_route53_zone.hawordpress.name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "elk" {
  zone_id = data.aws_route53_zone.hawordpress.zone_id
  name    = "elk.${data.aws_route53_zone.hawordpress.name}"
  type    = "A"

  records = ["${aws_instance.kibana.public_ip}"]
  ttl     = 300
}


resource "aws_route53_zone" "elasticsearch" {
  name = "elasticsearch.ohavron-ocg1.link"

  vpc {
    vpc_id = aws_vpc.hawordpress.id
  }
}


resource "aws_route53_record" "elasticsearch" {
  zone_id = aws_route53_zone.elasticsearch.zone_id
  name    = aws_route53_zone.elasticsearch.name
  type    = "A"

  records = ["${aws_instance.es_master_nodes[1].private_ip}"]
  ttl     = 300
}

resource "aws_route53_zone" "logstash" {
  name = "logstash.ohavron-ocg1.link"

  vpc {
    vpc_id = aws_vpc.hawordpress.id
  }
}

# resource "aws_route53_zone" "elk" {
#   name = "elk.ohavron-ocg1.link"
# }

# resource "aws_route53_record" "elk" {
#   zone_id = aws_route53_zone.elk.zone_id
#   name    = aws_route53_zone.elk.name
#   type    = "A"

#   records = ["${aws_instance.kibana.public_ip}"]
#   ttl     = 300
# }
