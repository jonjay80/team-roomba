terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "djroomba-project3-artifacts"
    key = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Name = "DJRoomba"
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "s3-website-roomba.team.com"
  # policy = file("policy.json")

  tags = {
    Name = "RoombaTestBucket"
  }
}

resource "aws_s3_bucket_acl" "test" {
  bucket = aws_s3_bucket.bucket.bucket
  acl    = "public-read"
}

# resource "aws_s3_object" "test" {
#   bucket       = aws_s3_bucket.bucket.bucket
#   key          = "index.html"
#   source       = "index.html"
#   content_type = "text/html"
#   acl          = "public-read"
#   etag         = filemd5("index.html")
# }

resource "aws_s3_bucket_website_configuration" "test" {
  bucket = aws_s3_bucket.bucket.bucket

  index_document {
    suffix = "index.html"
  }

  #error_document{}
  #routing_rule{}
}

resource "aws_dynamodb_table" "movies" {
  name           = "Roombas-Movies"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "movie1" {
  table_name = aws_dynamodb_table.movies.name
  hash_key   = aws_dynamodb_table.movies.hash_key

  item = jsonencode({
    "id" : { "S" : "0001" },
    "title" : { "S" : "Fight Club" },
    "director" : { "S" : "David Fincher" },
    "year" : { "N" : "1999" },
    "image" : { "S" : "https://upload.wikimedia.org/wikipedia/en/f/fc/Fight_Club_poster.jpg" },
  })
}

resource "aws_dynamodb_table_item" "movie2" {
  table_name = aws_dynamodb_table.movies.name
  hash_key   = aws_dynamodb_table.movies.hash_key

  item = jsonencode({
    "id" : { "S" : "0002" },
    "title" : { "S" : "The Matrix" },
    "director" : { "S" : "The Wachowskis" },
    "year" : { "N" : "1999" },
    "image" : { "S" : "https://upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg" },
  })
}

resource "aws_dynamodb_table_item" "movie3" {
  table_name = aws_dynamodb_table.movies.name
  hash_key   = aws_dynamodb_table.movies.hash_key

  item = jsonencode({
    "id" : { "S" : "0003" },
    "title" : { "S" : "Office Space" },
    "director" : { "S" : "Mike Judge" },
    "year" : { "N" : "1999" },
    "image" : { "S" : "https://upload.wikimedia.org/wikipedia/en/8/8e/Office_space_poster.jpg" },
  })
}

resource "aws_dynamodb_table_item" "movie4" {
  table_name = aws_dynamodb_table.movies.name
  hash_key   = aws_dynamodb_table.movies.hash_key

  item = jsonencode({
    "id" : { "S" : "0004" },
    "title" : { "S" : "Half Baked" },
    "director" : { "S" : "Tamra Davis" },
    "year" : { "N" : "1998" },
    "image" : { "S" : "https://upload.wikimedia.org/wikipedia/en/1/10/Half-baked-dvd-cover.jpg" },
  })
}

resource "aws_lambda_function" "lambda" {
  filename         = "lambdaCRUD.zip"
  function_name    = "djroomba_crud"
  role             = aws_iam_role.lambda.arn
  handler          = "lambdaCRUD.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("lambdaCRUD.zip")
  environment {
    variables = {
      "TABLE_NAME" = "Roombas-Movies"
    }
  }
}

resource "aws_apigatewayv2_api" "djroomba" {
  name          = "djroomba_api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "djroomba" {
  api_id                 = aws_apigatewayv2_api.djroomba.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "djroomba_GET_ALL" {
  api_id    = aws_apigatewayv2_api.djroomba.id
  route_key = "GET /items"
  target    = "integrations/${aws_apigatewayv2_integration.djroomba.id}"
}

resource "aws_apigatewayv2_route" "djroomba_GET_ONE" {
  depends_on = [aws_apigatewayv2_route.djroomba_GET_ALL]
  api_id     = aws_apigatewayv2_api.djroomba.id
  route_key  = "GET /items/{id}"
  target     = "integrations/${aws_apigatewayv2_integration.djroomba.id}"
}

resource "aws_apigatewayv2_route" "djroomba_PUT" {
  depends_on = [aws_apigatewayv2_route.djroomba_GET_ONE]
  api_id     = aws_apigatewayv2_api.djroomba.id
  route_key  = "PUT /items"
  target     = "integrations/${aws_apigatewayv2_integration.djroomba.id}"
}

resource "aws_apigatewayv2_route" "djroomba_DELETE" {
  depends_on = [aws_apigatewayv2_route.djroomba_PUT]
  api_id     = aws_apigatewayv2_api.djroomba.id
  route_key  = "DELETE /items/{id}"
  target     = "integrations/${aws_apigatewayv2_integration.djroomba.id}"
}


resource "aws_apigatewayv2_stage" "djroomba" {
  api_id      = aws_apigatewayv2_api.djroomba.id
  name        = "djroomba"
  auto_deploy = "true"
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
resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "example"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
    origin_id                = "testid"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "testid"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "testid"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }


  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}