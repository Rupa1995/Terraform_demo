provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "sample_ec2" {
  ami = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "s3_bucket" {
    bucket = "rupa-tf-statefile-demo1"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}