
resource "aws_iam_role" "api-gateway-role" {
  name = var.api_gateway_role_name

  assume_role_policy = jsonencode(
    { "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "apigateway.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )
}

resource "aws_iam_policy" "api-gateway-policy" {
  name = var.api_gateway_policy_name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Action" : "${var.api_gateway_action}",
          "Resource" : "${var.s3_bucket_arn}/*",
        }
      ]
  })

}




resource "aws_iam_role_policy_attachment" "api-gateway-policy-attachment" {
  role       = aws_iam_role.api-gateway-role.name
  policy_arn = aws_iam_policy.api-gateway-policy.arn
}
resource "aws_iam_role_policy_attachment" "cloud-watch-policy-attachment" {
  role       = aws_iam_role.api-gateway-role.name
  policy_arn = var.cloud_watch_policy_arn
}
