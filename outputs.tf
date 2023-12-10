output "region_name" {
  value = data.aws_region.region.name
}

output "account_id" {
  value = data.aws_caller_identity.identity.account_id
}

output "lambda" {
  value = var.api_endpoints
}

output "openapi" {
  value = local.openAPI_spec
}