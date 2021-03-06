locals {
  hawordpress_asg_name = "hawordpress_asg"
}

data "aws_route53_zone" "hawordpress" {
  name = "ohavron-ocg1.link"
}

module "hawordpress" {
  source = "./modules/hawordpress"

  region = "eu-central-1"

  rds_subnet_ids             = [aws_subnet.hawordpress-database-eu-central-1a.id, aws_subnet.hawordpress-database-eu-central-1b.id]
  rds_multi_az               = true
  rds_vpc_security_group_ids = [aws_security_group.rds.id]
  rds_engine                 = "mysql"
  rds_engine_version         = "8.0.28"
  rds_family                 = "mysql8.0"
  rds_major_engine_version   = "8.0"
  rds_instance_class         = "db.t3.micro"
  rds_storage_type           = "gp2"
  rds_allocated_storage      = 5
  rds_max_allocated_storage  = 20
  rds_user                   = "user"
  rds_db_name                = "hawordpressdb"
  rds_port                   = "3306"

  efs_creation_token     = "efs"
  efs_perfomance_mode    = "generalPurpose"
  efs_throughput_mode    = "bursting"
  efs_encrypted          = "true"
  efs_security_group_ids = [aws_security_group.efs.id]
  efs-mt1_subnet_id      = aws_subnet.hawordpress-private-eu-central-1a.id
  efs-mt2_subnet_id      = aws_subnet.hawordpress-private-eu-central-1b.id

  asg_name_prefix                 = "hawordpress-"
  asg_name                        = local.hawordpress_asg_name
  asg_image_id                    = "ami-05f5f4f906feab6a7"
  asg_instance_type               = "t2.micro"
  asg_security_groups             = [aws_security_group.asg.id]
  asg_associate_public_ip_address = true
  asg_enable_monitoring           = true
  asg_min_size                    = 0
  asg_max_size                    = 2
  asg_desired_capacity            = 2
  asg_vpc_zone_identifier         = [aws_subnet.hawordpress-private-eu-central-1a.id, aws_subnet.hawordpress-private-eu-central-1b.id]

  alb_vpc_id                           = aws_vpc.hawordpress.id
  alb_subnets                          = [aws_subnet.hawordpress-public-eu-central-1a.id, aws_subnet.hawordpress-public-eu-central-1b.id]
  alb_security_groups                  = [aws_security_group.alb.id]
  alb_enable_cross_zone_load_balancing = true

  hawordpress_record_name    = data.aws_route53_zone.hawordpress.name
  hawordpress_record_zone_id = data.aws_route53_zone.hawordpress.zone_id

  ssh_key_name = "tf-kp2"
  ssh_key_path = "tf-kp.pub"
}

module "lambda_http_checker" {
  source = "./modules/lambda"

  vpc_subnet_ids         = [aws_subnet.hawordpress-private-eu-central-1a.id, aws_subnet.hawordpress-private-eu-central-1b.id]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  email_address          = file("./email_address")
  email_pass             = file("./email_pass")
}

data "aws_instances" "hawordpress_asg" {
  instance_tags = {
    "aws:autoscaling:groupName" = local.hawordpress_asg_name
  }
}

module "elk" {
  source = "./modules/elk"

  bastion_subnet_id              = aws_subnet.hawordpress-public-eu-central-1a.id
  bastion_vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  es_master_node_count                  = var.elk_es_master_node_count
  es_data_node_count                    = var.elk_es_data_node_count
  es_subnet_ids                         = [aws_subnet.hawordpress-private-eu-central-1a.id, aws_subnet.hawordpress-private-eu-central-1b.id]
  es_master_node_vpc_security_group_ids = [aws_security_group.elasticsearch_sg.id]
  es_data_node_vpc_security_group_ids   = [aws_security_group.elasticsearch_sg.id]
  es_connection_private_key_path        = "./tf-kp"

  connection_bastion_private_key_path = "./tf-kp"

  kibana_subnet_id                   = aws_subnet.hawordpress-public-eu-central-1a.id
  kibana_vpc_security_group_ids      = [aws_security_group.kibana_sg.id]
  kibana_connection_private_key_path = "./tf-kp"

  logstash_subnet_id                   = aws_subnet.hawordpress-private-eu-central-1b.id
  logstash_vpc_security_group_ids      = [aws_security_group.logstash_sg.id]
  logstash_connection_private_key_path = "./tf-kp"

  filebeat_connection_hosts            = data.aws_instances.hawordpress_asg.private_ips
  filebeat_count                       = length(data.aws_instances.hawordpress_asg.private_ips)
  filebeat_connection_private_key_path = "./tf-kp"

  elk_record_zone_id           = data.aws_route53_zone.hawordpress.zone_id
  elk_record_name              = "elk.${data.aws_route53_zone.hawordpress.name}"
  elasticsearch_zone_name      = "elasticsearch.${data.aws_route53_zone.hawordpress.name}"
  elasticsearch_zone_vpc_id    = aws_vpc.hawordpress.id
  logstash_zone_name           = "logstash.${data.aws_route53_zone.hawordpress.name}"
  logstash_zone_vpc_id         = aws_vpc.hawordpress.id
}
