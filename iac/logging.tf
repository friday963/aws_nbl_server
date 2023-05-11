# Resource "aws_cloudwatch_logs_group" creates a log group with the name /aws/flow-logs
# aws_flow_log creates the flow logs inside the log group just mentioned.  
# Notice we create a policy and a role and tie them together near the bottom.  Those need to be created and associated with the flow logs so they


resource "aws_flow_log" "flow_log_instance1" {
  depends_on = [aws_cloudwatch_log_group.log_group]
  
  log_destination    = aws_cloudwatch_log_group.log_group.arn
  traffic_type       = "ALL"
  eni_id             = aws_instance.subnet_1_instance.primary_network_interface_id
  iam_role_arn       = aws_iam_role.flow_log_role.arn
}

resource "aws_flow_log" "flow_log_instance2" {
  depends_on = [aws_cloudwatch_log_group.log_group]
  
  log_destination    = aws_cloudwatch_log_group.log_group.arn
  traffic_type       = "ALL"
  eni_id             = aws_instance.subnet_2_instance.primary_network_interface_id
  iam_role_arn       = aws_iam_role.flow_log_role.arn
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/flow-logs"
  retention_in_days = 30
}



resource "aws_iam_role" "flow_log_role" {
  name = "flow-log-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "flow_log_policy" {
  name        = "flow-log-policy"
  description = "Policy for VPC Flow Logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudWatchLogsWrite",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.log_group.arn}:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "flow_log_policy_attachment" {
  policy_arn = aws_iam_policy.flow_log_policy.arn
  role       = aws_iam_role.flow_log_role.name
}