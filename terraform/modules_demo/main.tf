provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source              = "./modules/ec2_instances"
  ami_value           = "ami-04b4f1a9cf54c11d0"
  instance_type_value = "t2.micro"
}