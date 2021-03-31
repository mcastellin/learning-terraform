resource "aws_cloudwatch_event_rule" "workers_node_termination" {
  provider    = aws.region_workers
  name        = "Jenkins-workers-nodes-termination"
  description = "Triggers when a Jenkins worker node is terminated by the autoscaling group"

  event_pattern = jsonencode({
    source = [
      "aws.autoscaling"
    ]
    "detail-type" = [
      "EC2 Instance-terminate Lifecycle Action"
    ]
    detail = {
      AutoScalingGroupName = [
        aws_autoscaling_group.jenkins_workers_asg.name
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "deregister_worker_node" {
  provider  = aws.region_workers
  target_id = "DeregisterJenkinsWorker"

  # workaround to address the ssm automation arn and not the document definition
  arn = replace(
    aws_ssm_document.jenkins_deregistration_action.arn,
    "document/",
    "automation-definition/"
  )
  rule     = aws_cloudwatch_event_rule.workers_node_termination.name
  role_arn = aws_iam_role.invoke_ssm_automation_from_cloudwatch.arn

  input_transformer {
    input_paths = {
      instanceid = "$.detail.EC2InstanceId"
    }
    input_template = <<INPUT_TEMPLATE_EOF
    {
        "InstanceId": [<instanceid>],
        "automationAssumeRole": ["${aws_iam_role.ssm_automation_role.arn}"]
    }
    INPUT_TEMPLATE_EOF
  }
}