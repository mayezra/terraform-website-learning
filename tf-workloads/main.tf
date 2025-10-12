provider "aws" {
  region = "eu-central-1"
}

module "static_site" {
  source      = "../../tf-modules"
  bucket_name = local.bucket_name
}

