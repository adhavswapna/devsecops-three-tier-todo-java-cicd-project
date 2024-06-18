resource "aws_spot_instance_request" "jenkins-three-tier-cicd" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.2xlarge"
  subnet_id              = aws_subnet.jenkins-public-subnet1.id
  key_name               = "swapna"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins-todo-sg.id]
  user_data              = templatefile("./install-tools.sh", {})

  tags = {
    Name = "jenkins-three-tier-cicd"
  }
}
