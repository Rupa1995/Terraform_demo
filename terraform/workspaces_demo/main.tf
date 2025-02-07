provider "aws" {
  region = "us-east-1"
}

variable "ami" {
  description = "value for ami"
}

variable "instance_type" {
  description = "value for instance type"
  type = map(string)
  default = {
    "dev" = "t2.micro"
    "stage" = "t2.small"
  }
}

module "ec2_instance" {
  source              = "./modules/ec2_instances"
  ami_value           = var.ami
  instance_type_value = lookup(var.instance_type,terraform.workspace,"t2.micro")
}