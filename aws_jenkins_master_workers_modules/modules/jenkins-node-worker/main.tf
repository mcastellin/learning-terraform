terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
}

locals {
  ssh_key_public_file = format("%s.pub", var.ssh_key_file)
}

# Retrieve from the SSM parameter the latest ami version ID
data "aws_ssm_parameter" "linuxAmi" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# SSH Key generation to access EC2 instances
# generate keypair with `ssh-keygen -t rsa`

resource "aws_key_pair" "ssh_jenkins" {
  key_name   = "jenkins-worker"
  public_key = file(local.ssh_key_public_file)
}

# Create AMIs
# NOTE: for ansible provisioners to work we need to have boto3 library installed
# in the node we use to run our terraform scripts
# pip3 install boto3 --user
resource "aws_instance" "jenkins-workers" {
  # count is a default field available for any resource in terraform
  count = var.workers_count

  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_jenkins.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = var.vpc_sec_group_ids
  subnet_id                   = var.subnet_id
  tags = {
    "Name" = join("_", ["jenkins_master_tf", count.index + 1])
  }

  # Dependency on master node is guaranteed by the wired parameter "master_ip"
  # depends_on = [
  #   aws_main_route_table_association.set-worker-default-rt-assoc,
  #   aws_instance.jenkins-master
  # ]

  provisioner "local-exec" {
    command = <<EOF
    aws --profile ${var.aws_profile} ec2 wait instance-status-ok --region ${var.region} --instance-ids ${self.id}
    ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name} master_ip=${var.master_ip}' ansible_templates/jenkins_worker.yaml
    EOF
  }
}

# Workaround to implement destroy provisioner with additional parameter
resource "null_resource" "destroy_provisioner" {
  count = var.workers_count
  triggers = {
    ssh_key_file     = var.ssh_key_file
    instance_ip_addr = aws_instance.jenkins-workers[count.index].public_ip
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "/home/ec2-user/deregister.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(self.triggers.ssh_key_file)
      host        = self.triggers.instance_ip_addr
    }
  }
}