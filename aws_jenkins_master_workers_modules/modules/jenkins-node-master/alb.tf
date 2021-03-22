resource "aws_lb" "application-lb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sec_group_id]
  subnets            = var.lb_subnets
  tags = {
    "Name" = "Jenkins-LB"
  }
}

resource "aws_lb_target_group" "app-lb-tg" {
  name        = "app-lb-tg"
  port        = var.webserver_port
  target_type = "instance"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = var.webserver_port
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    "Name" = "Jenkins-target-group"
  }
}

resource "aws_lb_listener" "jenkins-listener-http" {
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.app-lb-tg.arn
  # }
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# create listener for HTTPS
resource "aws_lb_listener" "jenkins-listener-https" {
  load_balancer_arn = aws_lb.application-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkin-master-attach" {
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = aws_instance.jenkins-master.id
  port             = var.webserver_port
}