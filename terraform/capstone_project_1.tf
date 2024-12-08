provider "aws" {
 alias  = "secondary"
 region = var.region
 access_key = var.access_key
 secret_key = var.secret_key
}


resource "aws_vpc" "sa-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet-1" {
  provider      = aws.secondary
  depends_on = [aws_vpc.sa-vpc]
  vpc_id     = aws_vpc.sa-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_route_table" "sa-route-table" {
  vpc_id = aws_vpc.sa-vpc.id

tags = {
    Name = "sa-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.sa-route-table.id
}

resource "aws_internet_gateway" "gw" {
  depends_on = [aws_vpc.sa-vpc]
  vpc_id = aws_vpc.sa-vpc.id

  tags = {
    Name = "gw"



  }
}

resource "aws_route" "sa-route" {
  route_table_id            = aws_route_table.sa-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

variable "sg_ports" {
type = list(number)
default = [80,8080,22,443]
}


resource "aws_security_group" "sa-sg" {
  name        = "sa-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.sa-vpc.id
  dynamic ingress {
   for_each = var.sg_ports
   iterator = port
   content {
   from_port        = port.value
    to_port          = port.value
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
   egress {
   from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}

resource "tls_private_key" "mykey" {
  algorithm = "RSA"
}

resource "aws_key_pair" "aws_key" {
  key_name   = "web-key"
  public_key = tls_private_key.mykey.public_key_openssh

provisioner "local-exec" {
    command = "echo '${tls_private_key.mykey.private_key_openssh}' > ./web-key.pem"
}
}

resource "aws_instance" "myec2" {
  ami           = "ami-005fc0f236362e99f"
  instance_type = "t2.micro"
  key_name = "web-key"
  subnet_id = aws_subnet.subnet-1.id
  security_groups = [aws_security_group.sa-sg.id]

  tags = {
    Name = "Terraform-ec2"
  }



provisioner "remote-exec" {
 inline = [
    "sudo apt-get update -y",
    "sudo apt-get install -y nginx",
    "sudo systemctl start nginx"
  ]
    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = tls_private_key.mykey.private_key_pem
    host     = self.public_ip
  }

}

}

output "vpc-id" {

value = aws_vpc.sa-vpc.id

}

output "instance-id" {

value = aws_instance.myec2.id

}