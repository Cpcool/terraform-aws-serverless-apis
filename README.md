# terraform-aws-serverless-apis

```python

##main.tf## 

module "serverless-apis" {
  source  = "Cpcool/serverless-apis/aws"
  version = "2.0.0"

  api_name = "my-rest-api"

  api_endpoints = {
    "/health-check" = {
      "get" = "getHealthCheckStatus"
    }
  }
  environments = ["dev"]
}

```
```
Folder structure

├── artifacts
│   ├── getHealthCheckStatus
│   │   └── index.js
├── main.tf
