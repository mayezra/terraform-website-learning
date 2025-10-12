module "static_site" {
  source      = "../../tf-modules"   # points to your module folder
  bucket_name = local.bucket_name    # pass the real value into the module
}

