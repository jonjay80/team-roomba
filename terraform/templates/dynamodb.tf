terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "movies" {
  name           = "EverettMovies"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "Project 3"
  }
}

resource "aws_dynamodb_table_item" "movie1" {
  table_name = "${aws_dynamodb_table.movies.name}"
  hash_key   = "${aws_dynamodb_table.movies.hash_key}"

  item = jsonencode({
  "id": {"S": "0001"},
  "title": {"S": "Fight Club"},
  "director": {"S": "David Fincher"},
  "year": {"N": "1999"},
  "image": {"S": "https://upload.wikimedia.org/wikipedia/en/f/fc/Fight_Club_poster.jpg"},
})
}

resource "aws_dynamodb_table_item" "movie2" {
  table_name = "${aws_dynamodb_table.movies.name}"
  hash_key   = "${aws_dynamodb_table.movies.hash_key}"

  item = jsonencode({
  "id": {"S": "0002"},
  "title": {"S": "The Matrix"},
  "director": {"S": "The Wachowskis"},
  "year": {"N": "1999"},
  "image": {"S": "https://upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg"},
})
}

resource "aws_dynamodb_table_item" "movie3" {
  table_name = "${aws_dynamodb_table.movies.name}"
  hash_key   = "${aws_dynamodb_table.movies.hash_key}"

  item = jsonencode({
  "id": {"S": "0003"},
  "title": {"S": "Office Space"},
  "director": {"S": "Mike Judge"},
  "year": {"N": "1999"},
  "image": {"S": "https://upload.wikimedia.org/wikipedia/en/8/8e/Office_space_poster.jpg"},
})
}

resource "aws_dynamodb_table_item" "movie4" {
  table_name = "${aws_dynamodb_table.movies.name}"
  hash_key   = "${aws_dynamodb_table.movies.hash_key}"

  item = jsonencode({
  "id": {"S": "0004"},
  "title": {"S": "Half Baked"},
  "director": {"S": "Tamra Davis"},
  "year": {"N": "1998"},
  "image": {"S": "https://upload.wikimedia.org/wikipedia/en/1/10/Half-baked-dvd-cover.jpg"},
})
}