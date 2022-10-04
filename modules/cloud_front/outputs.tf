output "domain_name" {
  value = aws_cloudfront_distribution.cloud-front-distribution.domain_name
}
output "hosted_zone_id" {
  value = aws_cloudfront_distribution.cloud-front-distribution.hosted_zone_id
}
