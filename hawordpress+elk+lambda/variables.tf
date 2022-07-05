variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "elk_es_master_node_count" {
  type = number
  default = 2
}

variable "elk_es_data_node_count" {
  type = number
  default = 4
}
