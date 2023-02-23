resource "aws_lambda_function" "lambda" {
  filename         = "lambdaCRUD.zip"
  function_name    = "djroomba_crud"
  role             = aws_iam_role.lambda.arn
  handler          = "lambdaCRUD.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("lambdaCRUD.zip")
  environment {
    variables = {
      "TABLE_NAME" = "EverettMovies"
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "djroomba_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda" {
  name   = "djroomba_lambda_role_policy"
  role   = aws_iam_role.lambda.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_apigatewayv2_api.djroomba.execution_arn}/*/*"
}