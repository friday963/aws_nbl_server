# Create two instances with an ubuntu image (couldn't get my go program to work in default amazon linux instance)
# subnet_id places the instance inside the subnet defined.
# security_groups simply attaches a security group to the ENI of the instance.
# user_data specifies the txt file found in this same package and runs that on the image when its instantiated.
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