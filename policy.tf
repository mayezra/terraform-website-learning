resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true # ignores any public ACLs on objects
  block_public_policy     = true # same idea at read time
  ignore_public_acls      = true # rejects bucket policies that make it public
  restrict_public_buckets = true # denies requests to public buckets
}

