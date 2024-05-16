# provider.tf

locals {
  aws_keys = jsondecode(file("aws_keys.json"))
}
# Specify the provider and access details
provider "aws" {
  access_key = local.aws_keys.aws_access_key
  secret_key = local.aws_keys.aws_secret_key
  region     = var.region
}