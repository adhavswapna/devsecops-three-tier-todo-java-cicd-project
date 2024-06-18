# Create VPC
resource "aws_vpc" "jenkins-vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "jenkins-vpc"
  }
}

# Create subnets
resource "aws_subnet" "jenkins-public-subnet1" {
  vpc_id     = aws_vpc.jenkins-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-public-subnet1"
  }
}


# Create internet gateway
resource "aws_internet_gateway" "jenkins-todo-igw" {
  vpc_id = aws_vpc.jenkins-vpc.id

  tags = {
    Name = "jenkins-todo-igw"
  }
}

# Create route table
resource "aws_route_table" "jenkins-todo-route-table" {
  vpc_id = aws_vpc.jenkins-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins-todo-igw.id
  }

  tags = {
    Name = "jenkins-todo-route-table"
  }
}

# Create route table association
resource "aws_route_table_association" "jenkins-todo-RTA1" {
  subnet_id      = aws_subnet.jenkins-public-subnet1.id
  route_table_id = aws_route_table.jenkins-todo-route-table.id
}

#create security group
resource "aws_security_group" "jenkins-todo-sg" {
  name   = "jenkins-todo-sg"
  vpc_id = aws_vpc.jenkins-vpc.id

  ingress = [
    for port in [22, 80, 443, 9000, 8080, 3000, 8081, 27017] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = []
      self             = false
      prefix_list_ids  = []
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins-todo-sg"
  }
}
