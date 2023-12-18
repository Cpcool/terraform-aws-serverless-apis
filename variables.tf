variable "api_name" {
  description = "name of the api gateway"
}

variable "api_endpoints" {
  description = "Map of API endpoints and their associated methods and Lambda functions."
  type        = map(map(string))
}

# variable "lambda_functions" {
#   description = "Map of Lambda functions and their configurations."
#   type        = map(object({
#     runtime = string
#     handler = string
#     zip     = string
#   }))
# }

variable "environments" {
  description = "Name of environements"
  default = ["dev"]
  type = list(string)
}
