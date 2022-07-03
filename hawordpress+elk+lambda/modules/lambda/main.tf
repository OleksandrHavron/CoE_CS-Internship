module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name          = var.function_name
  description            = var.description
  handler                = var.handler
  runtime                = var.runtime
  source_path            = var.source_path
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
  attach_network_policy  = var.attach_network_policy
  publish                = var.publish
  layers                 = var.layers
  attach_policy_json     = var.attach_policy_json
  number_of_policy_jsons = var.number_of_policy_jsons
  policy_json            = var.policy_json

  allowed_triggers = {
    "EventBridge" = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.lambda_http_checker.arn
    }
  }

  environment_variables = {
    count         = 0
    email_pass    = var.email_pass
    email_address = var.email_address
  }
}

resource "aws_cloudwatch_event_rule" "lambda_http_checker" {
  name                = var.cloudwatch_event_rule_name
  description         = var.cloudwatch_event_rule_description
  schedule_expression = var.schedule_expression
  is_enabled          = var.is_enabled
}

resource "aws_cloudwatch_event_target" "scan_ami_lambda_function" {
  rule = aws_cloudwatch_event_rule.lambda_http_checker.name
  arn  = module.lambda_function.lambda_function_arn
}
