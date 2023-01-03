data "aws_iam_policy_document" "network_interface" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "network_interface" {
  for_each = var.vpc_config != null ? toset(["vpc-network-interface"]) : toset([])

  name   = each.value
  policy = data.aws_iam_policy_document.network_interface.json
  role   = aws_iam_role.lambda.id
}
