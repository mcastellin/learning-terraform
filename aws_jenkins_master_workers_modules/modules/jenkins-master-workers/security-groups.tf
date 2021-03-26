resource "aws_security_group" "jenkins_alb_secgroup" {
  provider = aws.region_master
  name     = "jenkins-alb-secgroup"

  vpc_id = var.master_vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "jenkins_master_secgroup" {
  provider = aws.region_master
  name     = "jenkins-master-secgroup"

  vpc_id = var.master_vpc_id

  ingress {
    description     = "allow application access from load balancer security group"
    from_port       = var.webserver_port
    to_port         = var.webserver_port
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_alb_secgroup.id]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "allow_public_ssh" {
  provider = aws.region_master
  name     = "allow_public_ssh"

  vpc_id = var.master_vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}