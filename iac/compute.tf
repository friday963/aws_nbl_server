resource "aws_instance" "subnet_1_instance" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_1.id

  tags = {
    Name = "go-application-server"
  }
  security_groups = [aws_security_group.web_server_sg.id]
  user_data       = file("userdata.txt")
}
resource "aws_instance" "subnet_2_instance" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_2.id

  tags = {
    Name = "go-application-server"
  }
  security_groups = [aws_security_group.web_server_sg.id]
  user_data       = file("userdata.txt")

}