data "aws_region" "region" {}
data "aws_caller_identity" "identity" {}

 locals {
  openAPI_spec = {
    for endpoint, spec in var.api_endpoints : endpoint => {
      for method, lambdaa in spec : method => {
        x-amazon-apigateway-integration = {
          type       = "aws_proxy"
          httpMethod = "POST"
          uri        = "arn:aws:apigateway:${data.aws_region.region.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:${lambdaa}/invocations"
        }
      }
    }
  }
}

locals {
  handler_functions = flatten([for endpoint in var.api_endpoints : values(endpoint)])
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.api_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  body = jsonencode({
    openapi = "3.0.1"
    paths   = local.openAPI_spec
  })
}

 module "lambda_function" {
  source                                  = "terraform-aws-modules/lambda/aws"
  for_each                                = toset(local.handler_functions)
  function_name                           = each.key
  runtime                                 = "nodejs16.x"
  handler                                 = "index.handler"
  source_path                             = "${path.root}/src/artifacts/${each.key}/"
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    api-gateway = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
    }
  }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }
   lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  for_each =  toset(var.environments)
  stage_name    = each.value
}

