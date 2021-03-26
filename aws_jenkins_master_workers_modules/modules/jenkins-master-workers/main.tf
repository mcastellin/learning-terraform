terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws      = ">=3.0.0"
    template = ">=2.2.0"
  }
}

locals {
  master_public_ssh_key = "${var.master_ssh_key}.pub"
}

# Read the latest Amazon Linux AMI from the parameter store
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region_master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "master_key_pair" {
  provider   = aws.region_master
  key_name   = "jenkins-master-keypair"
  public_key = file(local.master_public_ssh_key)
}

resource "aws_autoscaling_group" "jenkins_master_asg" {
  provider = aws.region_master
  # Workaround to foce autoscaling group recreation 
  name     = "jenkins_master_asg--${aws_launch_configuration.jenkins_master_launch_config.id}"
  max_size = 1
  min_size = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.jenkins_lb_tg.arn]

  launch_configuration = aws_launch_configuration.jenkins_master_launch_config.id
  vpc_zone_identifier  = var.master_subnets_list
}

# Using the newer launch_configuration to define instances for the autoscaling group
resource "aws_launch_configuration" "jenkins_master_launch_config" {
  provider      = aws.region_master
  name_prefix   = "jenkins-master-"
  image_id      = data.aws_ssm_parameter.linuxAmi.value
  instance_type = var.master_instance_type
  key_name      = aws_key_pair.master_key_pair.key_name
  security_groups = [
    aws_security_group.allow_public_ssh.id,
    aws_security_group.jenkins_master_secgroup.id
  ]
  associate_public_ip_address = true

  user_data = templatefile(
    "${path.module}/scripts/master_init.tpl",
    {
      "foo" = "bar"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
