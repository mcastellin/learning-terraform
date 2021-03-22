resource "aws_security_group" "lb-sg" {
  provider    = aws.region_master
  name        = "lb-sg"
  description = "Allow HTTP and HTTPs traffic to Jenkins SG"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow all https traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  ingress {
    description = "Allow all http traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  egress {
    description = "Allow all egress traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}


resource "aws_security_group" "jenkins-sg" {
  provider    = aws.region_master
  name        = "jenkins-sg"
  description = "Allow tcp 8080 and 22 traffic"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow 22 from our external IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description     = "Allow anyone 8080 tcp traffic"
    from_port       = var.webserver_port
    to_port         = var.webserver_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }
  ingress {
    description = "Allow all traffic from peered VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.0/24"]
  }
  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "jenkins-worker-sg" {
  provider    = aws.region_worker
  name        = "jenkins-worker-sg"
  description = "Allow ssh traffic from the jenkins master nodes"
  vpc_id      = aws_vpc.vpc_worker.id
  ingress {
    description = "Allow 22 from our public ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow ssh traffic from jenkins master"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}