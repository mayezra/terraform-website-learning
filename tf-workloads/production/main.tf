module "static_site" {
  source      = "../../tf-modules/s3-static-website"

  bucket_name = local.bucket_name
  tags        = local.common_tags  
}
