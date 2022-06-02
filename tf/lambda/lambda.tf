module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "lambda_handler"
  description   = "My awesome lambda function"
  handler       = "function.lambda_handler"
  runtime       = "python3.9"

  source_path = "./function.py"

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  attach_network_policy  = true
  publish = true

  layers = [
      "arn:aws:lambda:eu-central-1:336392948345:layer:AWSDataWrangler-Python39:4"
  ]

  allowed_triggers = {
    "EventBridge" = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.lambda_http_checker.arn
    }
  }

  environment_variables = {
    count = 0
    email_pass = "bbdfbjdzgvlaykum"
    email_address = "stigua25@gmail.com"
  }

  tags = {
    Name = "my-lambda1"
  }
}

resource "aws_cloudwatch_event_rule" "lambda_http_checker" {
  name        = "lambda_http_checker"
  description = "Makes HTTP calls to some endpoint"

  schedule_expression = "rate(5 minutes)"

  is_enabled = false
}

resource "aws_cloudwatch_event_target" "scan_ami_lambda_function" {
  rule = aws_cloudwatch_event_rule.lambda_http_checker.name
  arn  = module.lambda_function.lambda_function_arn
}
