resource "aws_vpc" "nlb_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.nlb_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.nlb_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_lb" "my_nlb" {
  name               = "golang-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  #   security_groups    = [aws_security_group.nlb_sg.id]

  enable_deletion_protection = false

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

resource "aws_lb_target_group" "nlb_tg" {
  name_prefix = "ec2-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.nlb_vpc.id

  health_check {
    protocol = "TCP"
  }

  depends_on = [aws_lb.my_nlb]
}
resource "aws_lb_target_group_attachment" "attachment_1" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = aws_instance.subnet_1_instance.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attachment_2" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = aws_instance.subnet_2_instance.id
  port             = 80
}


resource "aws_internet_gateway" "nlb_igw" {
  vpc_id = aws_vpc.nlb_vpc.id

  tags = {
    Name = "go-application-igw"
  }
}

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.nlb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nlb_igw.id
  }

  tags = {
    Name = "my-public-route-table"
  }
}

resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.my_public_rt.id
}