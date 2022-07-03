variable "es_master_nodes_number" {
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

variable "es_data_nodes_number" {
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

variable "kibana_ami" {
  type    = string
  default = "ami-05f5f4f906feab6a7"
}

variable "kibana_instance_type" {
  type    = string
  default = "t2.small"
}

variable "logstash_count" {
    type = number
    default = 2
}

variable "logstash_ami" {
    type = string
    default = "ami-05f5f4f906feab6a7"
}
variable "logstash_instance_type" {
    type = string
    default = "t2.small"
}



variable "aws_route53_zone_elasticsearch" {
  type = string
  description = "Hosted zone name for Elastic Search"
  default = "elasticsearch.${var.aws_route53_zone_name}"
}

variable "aws_route53_zone_logstash" {
  type = string
  description = "Hosted zone name for Logstash"
  default = "logstash.${var.aws_route53_zone_name}"
}

variable "aws_route53_zone_kibana" {
  type = string
  description = "Hosted zone name for Kibana"
  default = "elk.${var.aws_route53_zone_name}"
}
