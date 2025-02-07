terraform {
  backend "s3" {
    bucket = "rupa-tf-statefile-demo1"
    region = "us-east-1"
    key = "rupa/terraform.tfstate"
    dynamodb_table = "terraform-lock"
  }
}
