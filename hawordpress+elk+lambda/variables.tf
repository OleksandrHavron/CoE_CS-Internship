variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "domain_name" {
  description = "Domain name for WordPress"
  type        = string
  default     = "ohavron-ocg1.link"
}

variable "domain_name_zone_id" {
  description = "Zone id of domain_name"
  type        = string
  default     = "Z067633235P5TW5UJ6PXY"
}

variable "name_prefix" {
  type    = string
  default = "education-"
}

variable "asg_image_id" {
  description = "AMI of the AutoScaling Group instances.(Default=Amazon Linux 2)"
  type        = string
  default     = "ami-05f5f4f906feab6a7"
}

variable "asg_instance_type" {
  description = "EC2 instance type for AutoScaling Group"
  type        = string
  default     = "t2.micro"
}

variable "asg_min_size" {
  description = "Minimum size of AutoScaling Group"
  type        = number
  default     = 0
}

variable "asg_max_size" {
  description = "Maximum size of AutoScaling Group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Size of AutoScaling Group"
  type        = number
  default     = 2
}

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
