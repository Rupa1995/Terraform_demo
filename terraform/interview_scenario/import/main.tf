provider "aws" {
  region = "us-east-1"
}

import {
  id = "i-0dc0a17c17d49111e" #instance id to be imported
  to = aws_instance.example1
}