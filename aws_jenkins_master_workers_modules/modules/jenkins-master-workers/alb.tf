resource "aws_lb" "jenkins_alb" {
  provider           = aws.region_master
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins_alb_secgroup.id]
  subnets            = var.master_vpc.subnets
  tags = {
    "Name" = "Jenkins-ALB"
  }
}

resource "aws_lb_target_group" "jenkins_lb_tg" {
  provider    = aws.region_master
  name        = "jenkins-lb-tg"
  port        = var.webserver_port
  target_type = "instance"
  vpc_id      = var.master_vpc.id
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

resource "aws_lb_target_group_attachment" "jenkins_master_attach" {
  provider         = aws.region_master
  target_group_arn = aws_lb_target_group.jenkins_lb_tg.arn
  target_id        = aws_instance.jenkins_master.id
  port             = var.webserver_port
}

# listener configuration with ACM certificate
resource "aws_lb_listener" "jenkins_listener_https" {
  count = var.ssl_enabled ? 1 : 0

  provider          = aws.region_master
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_lb_tg.arn
  }
}

resource "aws_lb_listener" "jenkins_listener_http" {
  count = var.ssl_enabled ? 1 : 0

  provider          = aws.region_master
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# listener configuration without ACM certificate

resource "aws_lb_listener" "jenkins_listener_http_only" {
  count = var.ssl_enabled ? 0 : 1

  provider          = aws.region_master
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_lb_tg.arn
  }
}
