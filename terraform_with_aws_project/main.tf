resource "aws_vpc" "tfvpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.tfvpc.id
  cidr_block              = var.sub1_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true #indicate that instances launched into the subnet should be assigned a public IP address. Default is false.
  tags = {
    Name = "Subnet1"
  }
}
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.tfvpc.id
  cidr_block              = var.sub2_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true #indicate that instances launched into the subnet should be assigned a public IP address. Default is false.
  tags = {
    Name = "Subnet2"
  }
}

resource "aws_internet_gateway" "tfigw" {
  vpc_id = aws_vpc.tfvpc.id
}

resource "aws_route_table" "tfroute" {
  vpc_id = aws_vpc.tfvpc.id

  route {
    cidr_block = "0.0.0.0/0"                   #access from everywhere
    gateway_id = aws_internet_gateway.tfigw.id #connect to my igw

  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.tfroute.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.tfroute.id
}

resource "aws_security_group" "webSG" {
  name        = "web sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.tfvpc.id

  tags = {
    Name = "web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP" {
  security_group_id = aws_security_group.webSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH" {
  security_group_id = aws_security_group.webSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.webSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_s3_bucket" "tf_bucket" {
  bucket = "rupa-tf-bucket"
}

resource "aws_instance" "webServer1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSG.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webServer2" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSG.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))
}

#create alb
resource "aws_lb" "tf_lb" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webSG.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tf_lb_tg" {
  name     = "tf-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tfvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tf_lb_tg.arn
  target_id        = aws_instance.webServer1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tf_lb_tg.arn
  target_id        = aws_instance.webServer2.id
  port             = 80
}

resource "aws_lb_listener" "tf_listner" {
  load_balancer_arn = aws_lb.tf_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tf_lb_tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.tf_lb.dns_name
}