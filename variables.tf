# Lambda
variable "region" {
  description = "where you are creating the Lambda, ap-south-1."
  type        = string
}

variable "role_arn" {
  description = "role_arn for resource creation."
  type        = string
}

variable "name" {
  description = "Unique name for your Lambda Function."
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code."
  type        = string
}

variable "runtime" {
  description = "Identifier of the function's runtime."
  type        = string
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128."
  default     = 128
}

variable "timeout" {
  type        = number
  description = "Amount of time your Lambda Function has to run in seconds. Defaults to 3."
  default     = 3
}


# Apigateway
variable "apiname" {
  type        = string
  description = "Name of the REST API. If importing an OpenAPI specification via the body argument, this corresponds to the info.title field. If the argument value is different than the OpenAPI value, the argument value will override the OpenAPI value."
}

variable "endpoint_types" {
  type        = list(string)
  description = "List of endpoint types. This resource currently only supports managing a single value. Valid values: EDGE, REGIONAL or PRIVATE. If unspecified, defaults to EDGE."
}

variable "apiresource_path_part" {
  type        = string
  description = "Last path segment of this API resource."
}

variable "http_method" {
  type        = string
  description = "HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)"
}

variable "authorization" {
  type        = string
  description = "Type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)"
  default     = "NONE"
}

variable "type" {
  type        = string
  description = "Integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
}

variable "integration_http_method" {
  type        = string
  description = "Integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g., Lambda function can only be invoked via POST."
}

variable "timeout_milliseconds" {
  type        = number
  default     = 29000
  description = "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
}