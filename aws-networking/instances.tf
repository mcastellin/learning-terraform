# Retrieve from the SSM parameter the latest ami version ID
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "linuxAmiWorker" {
  provider = aws.region-worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# SSH Key generation to access EC2 instances
# generate keypair with `ssh-keygen -t rsa`

resource "aws_key_pair" "ssh-jenkins-master" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "ssh-jenkins-worker" {
  provider   = aws.region-worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}


# Create AMIs
resource "aws_instance" "jenkins-master" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.ssh-jenkins-master.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id
  tags = {
    # the Name tag is important because we're going to use it
    # as a reference for the dynamic Ansible store
    "Name" = "jenkins_master_tf"
  }
  depends_on = [
    aws_main_route_table_association.set-master-default-rt-assoc
  ]
}


resource "aws_instance" "jenkins-workers" {
  provider = aws.region-worker

  # count is a default field available for any resource in terraform
  count = var.workers-count

  ami                         = data.aws_ssm_parameter.linuxAmiWorker.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.ssh-jenkins-worker.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-worker-sg.id]
  subnet_id                   = aws_subnet.subnet_1_worker.id
  tags = {
    "Name" = join("_", ["jenkins_master_tf", count.index + 1])
  }
  depends_on = [
    aws_main_route_table_association.set-worker-default-rt-assoc,
    aws_instance.jenkins-master
  ]
}