# Lambda execution role resource
resource "aws_iam_role" "lambda_role" {
  name               = "${var.name}-role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
]
}
EOF
  lifecycle {
    ignore_changes = [tags]
  }
}

# Lambda execution role policy resource
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "${var.name}-iam-policy"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
"Version": "2012-10-17",
"Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
]
}
EOF
  lifecycle {
    ignore_changes = [tags]
  }
}

# Lambda execution role policy attachment resource
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# Lambda archive_file resource
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python.zip"
}

#  Lambda function resource
resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "${path.module}/python/hello-python.zip"
  function_name = var.name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  memory_size   = var.memory_size
  timeout       = var.timeout
  lifecycle {
    ignore_changes = [tags]
  }
}

# Creating Lambda permission resource
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"

}

# Creating Api gateway trigger resource
resource "aws_api_gateway_rest_api" "New_API" {
  name = var.apiname
  endpoint_configuration {
    types = var.endpoint_types
  }
  lifecycle {
    ignore_changes = [tags]

  }
  depends_on = [aws_lambda_function.terraform_lambda_func]

}

# Creating Api gateway resource
resource "aws_api_gateway_resource" "apiResource" {
  rest_api_id = aws_api_gateway_rest_api.New_API.id
  parent_id   = aws_api_gateway_rest_api.New_API.root_resource_id
  path_part   = var.apiresource_path_part
  depends_on  = [aws_api_gateway_rest_api.New_API]

}

# Creating Api gateway method resource
resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.New_API.id
  resource_id   = aws_api_gateway_resource.apiResource.id
  http_method   = var.http_method
  authorization = var.authorization
}

# Creating Api gateway and lambda integration resource
resource "aws_api_gateway_integration" "apiResourceintegration" {
  rest_api_id             = aws_api_gateway_rest_api.New_API.id
  resource_id             = aws_api_gateway_resource.apiResource.id
  http_method             = var.http_method
  type                    = var.type
  integration_http_method = var.integration_http_method
  timeout_milliseconds    = var.timeout_milliseconds
  uri                     = aws_lambda_function.terraform_lambda_func.invoke_arn

}

# Creating Api gateway deployment resource
resource "aws_api_gateway_deployment" "api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.New_API.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.New_API.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}
# Creating Api gateway deployment stage resource
resource "aws_api_gateway_stage" "api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.api-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.New_API.id
  stage_name    = "${var.name}-stage"
  depends_on    = [aws_api_gateway_deployment.api-deployment]
}