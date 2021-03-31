terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws      = ">=3.0.0"
    template = ">=2.2.0"
  }
}

locals {
  master_public_ssh_key  = "${var.master_ssh_key}.pub"
  workers_public_ssh_key = "${var.workers_ssh_key}.pub"
  min_workers_count      = floor(var.workers_count * 0.6)
  max_workers_count      = ceil(var.workers_count * 1.4)
}

# -------------------------------------------------------------------------
# Jenkins master instance setup
# -------------------------------------------------------------------------
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region_master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "master_key_pair" {
  provider   = aws.region_master
  key_name   = "jenkins-master-keypair"
  public_key = file(local.master_public_ssh_key)
}

resource "aws_instance" "jenkins_master" {
  provider                    = aws.region_master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.master_instance_type
  key_name                    = aws_key_pair.master_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_master_secgroup.id]
  subnet_id                   = element(var.master_subnets_list, 0)

  user_data = templatefile(
    "${path.module}/scripts/master_init.tpl",
    {
      "foo" = "bar"
    }
  )
  provisioner "local-exec" {
    command = <<EOF
    aws --profile=default ec2 wait instance-status-ok --region ${var.master_region} --instance-ids ${self.id}
    EOF
  }

  tags = {
    "Name" = "Jenkins-master"
  }
}

# -------------------------------------------------------------------------
# Workers autoscaling group setup
# -------------------------------------------------------------------------
data "aws_ssm_parameter" "linuxAmiWorkers" {
  provider = aws.region_workers
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "workers_key_pair" {
  provider   = aws.region_workers
  key_name   = "jenkins-workers-keypair"
  public_key = file(local.workers_public_ssh_key)
}

resource "aws_autoscaling_group" "jenkins_workers_asg" {
  provider = aws.region_workers

  # workers autoscaling group depends on master node initialisation
  depends_on = [
    aws_instance.jenkins_master
  ]

  # Workaround to foce autoscaling group recreation 
  name             = "${aws_launch_configuration.jenkins_workers_launch_config.name}--autoscaling-group"
  max_size         = local.max_workers_count
  min_size         = local.min_workers_count
  desired_capacity = var.workers_count

  health_check_grace_period = 300
  health_check_type         = "EC2"

  launch_configuration = aws_launch_configuration.jenkins_workers_launch_config.id
  vpc_zone_identifier  = var.workers_subnets_list
}

# Using the newer launch_configuration to define instances for the autoscaling group
resource "aws_launch_configuration" "jenkins_workers_launch_config" {
  provider = aws.region_workers

  depends_on = [
    aws_instance.jenkins_master
  ]

  name_prefix                 = "jenkins-workers-"
  image_id                    = data.aws_ssm_parameter.linuxAmiWorkers.value
  instance_type               = var.workers_instance_type
  key_name                    = aws_key_pair.workers_key_pair.key_name
  security_groups             = [aws_security_group.jenkins_workers_secgroup.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile_for_ssm.name

  user_data = templatefile(
    "${path.module}/scripts/worker_init.tpl",
    {
      "master_ip" = aws_instance.jenkins_master.private_ip
      "region"    = var.workers_region
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}



# -------------------------------------------------------------------------
# Automation setup for worker nodes deregistration upon autoscaling
# -------------------------------------------------------------------------
resource "aws_autoscaling_lifecycle_hook" "workers_terminate_hook" {
  provider               = aws.region_workers
  name                   = "jenkins_workers_terminating_hook"
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers_asg.name
  heartbeat_timeout      = 60
  default_result         = "CONTINUE"
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}


resource "aws_ssm_document" "jenkins_deregistration_action" {
  provider      = aws.region_workers
  name          = "jenkins-workers-deregistration"
  document_type = "Automation"

  content = jsonencode({
    schemaVersion = "0.3"
    description   = "Deregister Jenkins worker node from master"
    assumeRole    = "{{automationAssumeRole}}"
    parameters = {
      automationAssumeRole = {
        type = "String"
      }
      InstanceId = {
        type = "String"
      }
    }
    mainSteps = [
      {
        name   = "deregisterNode"
        action = "aws:runCommand"
        inputs = {
          DocumentName = "AWS-RunShellScript"
          InstanceIds  = ["{{InstanceId}}"]
          Parameters = {
            commands = ["/home/ec2-user/deregister.sh"]
          }
        }
      }
    ]
  })
}
