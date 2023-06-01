provider "aws" {
    region = "us-east-1"
    profile = "default"
  
}

# Creating VPC

resource "aws_vpc" "terraform_vpc" {

    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "Terraform_vpc"
    }

}

resource "aws_subnet" "SubnetA" {
    vpc_id = aws_vpc.terraform_vpc.id
    cidr_block = "10.0.0.0/24"

    tags = {
      Name = "Terraform_SubnetA"
    }
  
}

resource "aws_internet_gateway" "Terrafrom_IGW" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "Terraform_IGW"
  }
}

resource "aws_route_table" "terraform_routeTable" {
    vpc_id = aws_vpc.terraform_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Terrafrom_IGW.id
    }

    tags = {
      Name = "Terraform_route"
    }
}

resource "aws_route_table_association" "rt_ass" {
  subnet_id = aws_subnet.SubnetA.id
  route_table_id = aws_route_table.terraform_routeTable.id
}

resource "aws_eip" "terraform_eip" {
    depends_on = [ aws_internet_gateway.Terrafrom_IGW ]
    instance = aws_instance.terraform_ec2.id
    tags = {
      Name = "terraform_IPaddress"
    }
}

resource "aws_eip" "terrafrom_eip2" {
    depends_on = [ aws_internet_gateway.Terrafrom_IGW ]
    instance = aws_instance.terraform1_ec2.id
    tags = {
      Name= "Terraform2_EIP"
    }
  
}

resource "aws_security_group" "terraform_sg" {
    vpc_id = aws_vpc.terraform_vpc.id
     ingress {
    description = "allow SSH connection to VM"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
    }

  ingress  {
    description = "allow http inbound traffic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

 ingress {
    description = "allow https inbound traffic"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   # ipv6_cidr_blocks = ["::/0"]
  }

 egress  {
  from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  #  ipv6_cidr_blocks = ["::/0"]
 }

  
}

resource "aws_instance" "terraform_ec2" {
    ami = "ami-0715c1897453cabd1"
    instance_type = "t2.large"
    key_name = "terrafor-testing"
    subnet_id = aws_subnet.SubnetA.id
    vpc_security_group_ids = [aws_security_group.terraform_sg.id]
    depends_on = [ aws_internet_gateway.Terrafrom_IGW ]
    user_data = <<-EOF
                #!/bin/bash
                # Use this for your user data (script from top to bottom)
                # install httpd (Linux 2 version)
                sudo yum update -y
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
                sudo echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
                EOF
    tags = {
      Name = "terraform_EC2"
    }
  
}

resource "aws_instance" "terraform1_ec2" {
    ami = "ami-0715c1897453cabd1"
    instance_type = "t2.large"
    key_name = "terrafor-testing"
    subnet_id = aws_subnet.SubnetA.id
    vpc_security_group_ids = [aws_security_group.terraform_sg.id]
    depends_on = [ aws_internet_gateway.Terrafrom_IGW ]
    user_data = <<-EOF
                #!/bin/bash
                # Use this for your user data (script from top to bottom)
                # install httpd (Linux 2 version)
                sudo yum update -y
                sudo yum install -y httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
                sudo echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
                EOF
    tags = {
      Name = "terraform_EC2"
    }
  
}

