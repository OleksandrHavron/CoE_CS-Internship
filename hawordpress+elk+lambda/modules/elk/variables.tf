variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "ssh_key_name" {
  type = string
  default = "tf-kp"
}

variable "ssh_key_path" {
  type    = string
  default = "./modules/elk/etc/tf-kp.pub"
}

variable "bastion_ami" {
  type    = string
  default = "ami-065deacbcaac64cf2"
}

variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "bastion_subnet_id" {
  type = string
}

variable "bastion_vpc_security_group_ids" {
  type = list(string)
}

variable "bastion_associate_public_ip_addressi" {
  type    = bool
  default = true
}

variable "es_master_node_count" {
  type    = number
  default = 2
}

variable "es_master_node_ami" {
  description = "AMI of the elasticsearch master node"
  type        = string
  default     = "ami-05f5f4f906feab6a7"
}

variable "es_master_node_instance_type" {
  description = "Instance type of the elasticsearch master node"
  type        = string
  default     = "t2.large"
}

variable "es_subnet_ids" {
  type = list(string)
}

variable "es_master_node_vpc_security_group_ids" {
  type = list(any)
}

variable "es_master_node_associate_public_ip_address" {
  type    = bool
  default = true
}

variable "es_master_node_template_file_path" {
  type    = string
  default = "./modules/elk/etc/elasticsearch_master_config.tpl"
}

variable "es_data_node_count" {
  type    = number
  default = 4
}

variable "es_data_node_ami" {
  description = "AMI of the elasticsearch master node"
  type        = string
  default     = "ami-05f5f4f906feab6a7"
}

variable "es_data_node_instance_type" {
  description = "Instance type of the elasticsearch master node"
  type        = string
  default     = "t2.large"
}

variable "es_data_node_vpc_security_group_ids" {
  type = list(any)
}

variable "es_data_node_associate_public_ip_address" {
  type    = bool
  default = true
}

variable "es_data_node_template_file_path" {
  type    = string
  default = "./modules/elk/etc/elasticsearch_data_config.tpl"
}

variable "es_cluster_name" {
  type    = string
  default = "cluster1"
}

variable "es_connection_user" {
  type    = string
  default = "ec2-user"
}

variable "es_connection_private_key_path" {
  type = string
}


variable "connection_bastion_user" {
  type    = string
  default = "ubuntu"
}

variable "connection_bastion_private_key_path" {
  type = string
}

variable "kibana_ami" {
  type    = string
  default = "ami-05f5f4f906feab6a7"
}

variable "kibana_instance_type" {
  type    = string
  default = "t2.small"
}

variable "kibana_subnet_id" {
  type = string
}

variable "kibana_vpc_security_group_ids" {
  type = list(string)
}

variable "kibana_associate_public_ip_address" {
  type    = bool
  default = true
}

variable "kibana_template_file_path" {
  type    = string
  default = "./modules/elk/etc/kibana_config.tpl"
}

variable "nginx_template_file_path" {
  type    = string
  default = "./modules/elk/etc/nginx.conf"
}

variable "oauth2_template_file_path" {
  type    = string
  default = "./modules/elk/etc/oauth2-proxy.cfg"
}

variable "oauth2_service_template_file_path" {
  type    = string
  default = "./modules/elk/etc/oauth2-proxy.service"
}

variable "kibana_connection_user" {
  type    = string
  default = "ec2-user"
}

variable "kibana_connection_private_key_path" {
  type = string
}


variable "logstash_count" {
  type    = number
  default = 2
}

variable "logstash_ami" {
  type    = string
  default = "ami-05f5f4f906feab6a7"
}
variable "logstash_instance_type" {
  type    = string
  default = "t2.small"
}

variable "logstash_subnet_id" {
  type = string
}

variable "logstash_vpc_security_group_ids" {
  type = list(string)
}

variable "logstash_associate_public_ip_address" {
  type    = bool
  default = true
}

variable "logstash_template_file_path" {
  type    = string
  default = "./modules/elk/etc/logstash_config.tpl"
}

variable "logstash_connection_user" {
  type    = string
  default = "ec2-user"
}

variable "logstash_connection_private_key_path" {
  type = string
}


variable "filebeat_template_file_path" {
  type    = string
  default = "./modules/elk/etc/logstash_config.tpl"
}

variable "filebeat_connection_user" {
  type    = string
  default = "ec2-user"
}

variable "filebeat_connection_hosts" {
  type    = list(string)
  default = []
}

variable "filebeat_count" {
  type    = number
  default = 0
}

variable "filebeat_connection_private_key_path" {
  type = string
}

# variable "aws_route53_zone_elasticsearch" {
#   type        = string
#   description = "Hosted zone name for Elastic Search"
#   default     = "elasticsearch.${var.aws_route53_zone_name}"
# }

# variable "aws_route53_zone_logstash" {
#   type        = string
#   description = "Hosted zone name for Logstash"
#   default     = "logstash.${var.aws_route53_zone_name}"
# }

# variable "aws_route53_zone_kibana" {
#   type        = string
#   description = "Hosted zone name for Kibana"
#   default     = "elk.${var.aws_route53_zone_name}"
# }
