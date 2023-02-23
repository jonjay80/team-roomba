resource "aws_s3_bucket" "bucket"{
    bucket = "s3-website-roomba.team.com"
    # policy = file("policy.json")

    tags = {
        Name = "RoombaTestBucket"
    }
}

resource "aws_s3_bucket_acl" "test" {
    bucket = aws_s3_bucket.bucket.bucket
    acl = "public-read"
}

resource "aws_s3_object" "test" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
  acl = "public-read"
  etag = filemd5("index.html")
}

resource "aws_s3_bucket_website_configuration" "test" {
    bucket = aws_s3_bucket.bucket.bucket

    index_document {
        suffix = "index.html"
    }

    #error_document{}
    #routing_rule{}
}