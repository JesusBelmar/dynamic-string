# Lambda@Edge function to handle viewer requests in CloudFront
resource "aws_lambda_function" "edge" {
  function_name    = "dynamic-string-edge"                    # Lambda function name
  runtime          = "python3.9"                              # Runtime environment
  handler          = "lambda_edge.handler"                    # Python handler (module.function)
  filename         = "../lambda/lambda.zip"                   # Packaged Lambda code
  source_code_hash = filebase64sha256("../lambda/lambda.zip") # Ensures redeployment on code change
  role             = aws_iam_role.lambda_edge.arn             # IAM role ARN for Lambda execution
  publish          = true                                     # Needed for Lambda@Edge (must use published versions)
  timeout          = 5                                        # Execution timeout in seconds
  memory_size      = 128                                      # Memory allocated (MB)

  # Optional: uncomment if you want to pass SSM parameter name via environment variables
  # environment {
  #   variables = {
  #     SSM_PARAM_NAME = "/challenge/dynamic_string"
  #   }
  # }
}

# IAM role for the Lambda@Edge function
resource "aws_iam_role" "lambda_edge" {
  name = "lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",    # Allows standard Lambda service
            "edgelambda.amazonaws.com" # Allows Lambda@Edge service
          ]
        }
      }
    ]
  })
}

# Attach AWS basic Lambda execution policy (logs to CloudWatch)
resource "aws_iam_role_policy_attachment" "lambda_edge" {
  role       = aws_iam_role.lambda_edge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom inline policy for Lambda to access the SSM parameter
resource "aws_iam_role_policy" "ssm_access" {
  name = "ssm-parameter-access"
  role = aws_iam_role.lambda_edge.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ssm:GetParameter"] # Only allows reading a parameter
        Effect   = "Allow"
        Resource = "arn:aws:ssm:*:*:parameter/challenge/dynamic_string"
      }
    ]
  })
}
