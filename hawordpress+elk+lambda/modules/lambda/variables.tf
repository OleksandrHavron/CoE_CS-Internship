variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "function_name" {
  type    = string
  default = "lambda_handler"
}

variable "description" {
  type    = string
  default = "Lambda HTTP checker"
}

variable "handler" {
  type    = string
  default = "function.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.9"
}

variable "source_path" {
  type    = string
  default = "./modules/lambda/scripts/function.py"
}

variable "vpc_subnet_ids" {
  type    = list(string)
  default = []
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "attach_network_policy" {
  type    = bool
  default = true
}

variable "publish" {
  type    = bool
  default = true
}

variable "layers" {
  type    = list(string)
  default = ["arn:aws:lambda:eu-central-1:336392948345:layer:AWSDataWrangler-Python39:4"]
}

variable "attach_policy_json" {
  type    = bool
  default = true
}

variable "number_of_policy_jsons" {
  type    = number
  default = 1
}

variable "policy_json" {
  type = string
  default = "{\n    \"Version\" : \"2012-10-17\",\n    \"Statement\" : [\n      {\n        \"Sid\" : \"VisualEditor0\",\n        \"Effect\" : \"Allow\",\n        \"Action\" : [\n          \"cloudwatch:PutMetricData\"\n        ],\n        \"Resource\": \"*\"\n      }\n]\n  }"
}

variable "email_address" {
  type = string
}

variable "email_pass" {
  type = string
}

variable "cloudwatch_event_rule_name" {
  type    = string
  default = "lambda_http_checker"
}

variable "cloudwatch_event_rule_description" {
  type    = string
  default = "Makes HTTP calls to some endpoint"
}

variable "schedule_expression" {
  type    = string
  default = "rate(5 minutes)"
}

variable "is_enabled" {
  type    = bool
  default = true
}


