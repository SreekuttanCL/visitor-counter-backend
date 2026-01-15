resource "aws_lambda_function" "visitor_lambda" {
  function_name = "visitor-counter-lambda"
  runtime       = "python3.11"
  handler       = "app.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn

  filename      = "${path.module}/../lambda/deployment.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/deployment.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.visitor_table.name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attach]
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Lambda access to DynamoDB visitor table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.visitor_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


