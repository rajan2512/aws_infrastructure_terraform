resource "aws_cloudfront_distribution" "cloud-front-distribution" {
  aliases = [var.cloud_front_custom_domain_name]

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = "true"
    default_ttl            = "0"
    max_ttl                = "0"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = var.cloud_front_target
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  enabled         = "true"
  http_version    = "http2"
  is_ipv6_enabled = "true"
  web_acl_id      = var.web_acl_id

  logging_config {
    bucket          = var.cloud_front_log_bucket
    include_cookies = "false"
  }

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"

    custom_header {
      name  = "X-Custom-Header"
      value = "12345"
    }

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = "5"
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = "30"
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    domain_name = var.cloud_front_target
    origin_id   = var.cloud_front_target
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    acm_certificate_arn            = var.cloud_front_certificate_arn
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}
