output "bucket_name"   { value = module.static_site.bucket_name }
output "cloudfront_url"{ value = "https://${module.static_site.cdn_domain}" }

