resource "aws_lb" "jenkins_alb" {
  provider           = aws.region_master
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins_alb_secgroup.id]
  subnets            = var.master_subnets_list
  tags = {
    "Name" = "Jenkins-ALB"
  }
}

resource "aws_lb_target_group" "jenkins_lb_tg" {
  provider    = aws.region_master
  name        = "jenkins-lb-tg"
  port        = var.webserver_port
  target_type = "instance"
  vpc_id      = var.master_vpc_id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    port     = var.webserver_port
    path     = "/login"
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    "Name" = "Jenkins-target-group"
  }
}

resource "aws_lb_listener" "jenkins_listener_http" {
  provider          = aws.region_master
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_lb_tg.arn
  }
}
