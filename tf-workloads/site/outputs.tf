output "bucket_name"   { value = module.static_site.bucket_name }             # reuse module output inside workload
output "cloudfront_url"{ value = "https://${module.static_site.cdn_domain}" } # user-friendly full HTTPS URL

