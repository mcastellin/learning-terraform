# -------------------------------------------------------------
# IAM Policies for ssm automation role
#
# This role is for the SSM automation document to be able to
# invoke other ssm commands and complete the EC2 lifecycle
# for the autoscaling group instance termination
# -------------------------------------------------------------
resource "aws_iam_role" "ssm_automation_role" {
  provider    = aws.region_workers
  name        = "SSM-Automation-Role"
  description = "Create a trust relationship with AWS Systems Manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.ssm_automation_to_complete_lifecycle.arn,
    aws_iam_policy.ssm_automation_document_policy.arn
  ]
}

resource "aws_iam_policy" "ssm_automation_to_complete_lifecycle" {
  provider    = aws.region_workers
  name        = "SSM-Automation-to-Complete-Lifecycle-Policy"
  description = "A policy to allow SSM automation documents to complete ec2 lifecycle actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["autoscaling:CompleteLifecycleAction"]
        Effect   = "Allow"
        Resource = aws_autoscaling_group.jenkins_workers_asg.arn
      }
    ]
  })
}

resource "aws_iam_policy" "ssm_automation_document_policy" {
  provider    = aws.region_workers
  name        = "SSM-Automation-Document-Policy"
  description = "A policy to allow all actions required by the automation document"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateImage",
          "ec2:DescribeImages",
          "ssm:DescribeInstanceInformation",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ssm:SendCommand"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:${var.workers_vpc.region}::document/AWS-RunShellScript"
      },
      {
        Action = [
          "ssm:SendCommand"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ec2:*:*:instance/*"
      }
    ]
  })
}

# -------------------------------------------------------------
# IAM Role for CloudWatch Events
#
# With this role cloudwatch events will be able to invoke
# the ssm automation document for node deregistration
# -------------------------------------------------------------
resource "aws_iam_role" "invoke_ssm_automation_from_cloudwatch" {
  provider    = aws.region_workers
  name        = "Invoke-SSM-automation-from-CloudWatch-Event"
  description = "Provides permissions to CloudWatch events to execute ssm automations"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.start_automation_execution.arn,
    aws_iam_policy.pass_role_ssm_automation.arn
  ]
}

resource "aws_iam_policy" "start_automation_execution" {
  provider    = aws.region_workers
  name        = "Start-SSM-automation-Policy"
  description = "provides permission to execute the automation document"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["ssm:StartAutomationExecution"]
        Effect = "Allow"
        Resource = [
          # workaround to address the ssm automation arn and not the document definition
          replace(
            "${aws_ssm_document.jenkins_deregistration_action.arn}:$DEFAULT",
            "document/",
            "automation-definition/"
          )
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "pass_role_ssm_automation" {
  provider    = aws.region_workers
  name        = "Pass-Role-SSM-Automation-Policy"
  description = "Allow to pass down the SSM-Automation-Role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.ssm_automation_role.arn
      }
    ]
  })
}


# -------------------------------------------------------------
# EC2 Role for SSM
#
# This role is for EC2 instances running SSM agents so they can
# be manged by ssm and run automations
# -------------------------------------------------------------
data "aws_iam_policy" "ec2_role_policy_for_ssm" {
  provider = aws.region_workers
  arn      = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role" "ec2_role_for_ssm" {
  provider    = aws.region_workers
  name        = "Jenkins-EC2-Role-for-SSM"
  description = "a role for ec2 instances to attach ssm agents"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [data.aws_iam_policy.ec2_role_policy_for_ssm.arn]
}

resource "aws_iam_instance_profile" "ec2_profile_for_ssm" {
  provider = aws.region_workers
  name     = "ec2-instance-profile-for-ssm"
  role     = aws_iam_role.ec2_role_for_ssm.name
}
