provider "aws" {
    region = "us-east-1"  # Set your desired AWS region
}

resource "aws_instance" "example" {
    ami           = "ami-04b4f1a9cf54c11d0"  # Specify an appropriate AMI ID
    instance_type = "t2.micro"
}