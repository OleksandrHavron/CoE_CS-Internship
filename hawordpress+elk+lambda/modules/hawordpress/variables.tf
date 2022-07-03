variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "rds_subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
  default     = []
}

variable "rds_multi_az" {
  type        = bool
  description = "Whether created db is multi availability zone"
  default     = true
}

variable "rds_vpc_security_group_ids" {
  description = "IDs of security groups"
  type        = list(string)
  default     = []
}

variable "rds_engine" {
  type    = string
  default = "mysql"
}

variable "rds_engine_version" {
  type    = string
  default = "8.0.28"
}

variable "rds_family" {
  type    = string
  default = "mysql8.0"
}

variable "rds_major_engine_version" {
  type    = string
  default = "8.0"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_storage_type" {
  type    = string
  default = "gp2"
}

variable "rds_allocated_storage" {
  type    = number
  default = 5
}

variable "rds_max_allocated_storage" {
  type    = number
  default = 20
}

variable "rds_user" {
  type    = string
  default = "user"
}

variable "rds_db_name" {
  type    = string
  default = "hawordpress-db"
}

variable "rds_port" {
  type    = string
  default = "3306"
}

variable "efs_creation_token" {
  type    = string
  default = "efs"
}

variable "efs_perfomance_mode" {
  type    = string
  default = "generalPurpose"
}

variable "efs_throughput_mode" {
  type    = string
  default = "bursting"
}

variable "efs_encrypted" {
  type    = string
  default = "true"
}

variable "efs_security_group_ids" {
  type    = list(string)
  default = []
}

variable "efs-mt1_subnet_id" {
  type    = string
  default = ""
}

variable "efs-mt2_subnet_id" {
  type    = string
  default = ""
}

variable "asg_name_prefix" {
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

variable "asg_security_groups" {
  type    = list(string)
  default = []
}

variable "asg_associate_public_ip_address" {
  type    = bool
  default = true
}

variable "asg_enable_monitoring" {
  type    = bool
  default = true
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

variable "asg_vpc_zone_identifier" {
  type    = list(string)
  default = []
}

variable "acm_domain_name" {
  description = "Domain name for WordPress"
  type        = string
  default     = "ohavron-ocg1.link"
}

variable "acm_domain_name_zone_id" {
  description = "Zone id of domain_name"
  type        = string
  default     = "Z067633235P5TW5UJ6PXY"
}

variable "alb_vpc_id" {
  type    = string
  default = ""
}

variable "alb_subnets" {
  type    = list(string)
  default = []
}

variable "alb_security_groups" {
  type    = list(string)
  default = []
}

variable "alb_enable_cross_zone_load_balancing" {
  type    = bool
  default = true
}

variable "aws_route53_zone_name" {
  type = string
  description = "ohavron-ocg1.link"
  default = ""
}
