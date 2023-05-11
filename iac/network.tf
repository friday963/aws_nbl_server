# Create the VPC
resource "aws_vpc" "nlb_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create two subnets to test cross zone load balancing
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

# Create a network load balancer.  Notice the resource is just called "aws_lb", the load balancer type could have said alb or network.
# Tie the subnets to the load balancer.

resource "aws_lb" "my_nlb" {
  name               = "golang-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  #   security_groups    = [aws_security_group.nlb_sg.id]

  enable_deletion_protection = false

  tags = {
    Environment = "nlb"
  }

}

# data resource used to pull in some information about the newly created load balancer.  Used when tying the flow logs and cloud watch logs together.
data "aws_lb" "my_nlb_name" {
  name = aws_lb.my_nlb.name
}

# creates a listener on the load balancer.  If it gets a request on this port it will forward to the targets (aka group of instances, containers, or lambdas).
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

# next three resource blocks work together to create a target group (just a grouping of compute or serverless resources)
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
# attach the resources to the target group created above.
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

# create an IGW so our resources can communicate with the the client considering this is an internet facing load balancer.
resource "aws_internet_gateway" "nlb_igw" {
  vpc_id = aws_vpc.nlb_vpc.id

  tags = {
    Name = "go-application-igw"
  }
}

# creates a new route table that has a default route to the internet.  This must be created or instances will not be able to communicate with clients.
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
# Lastly you need to associate the subnets with our servers to that route table.  This gives us fine grain details on how hosts in these two subnets will communicate with other resources.
resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.my_public_rt.id
}