resource "aws_iam_role" "tmp_lab_role" {
  name = "tmp_lab_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "s3_ip_server" {
  statement {
    sid = "OnlyAllowGetObjectOnSingleFile"

    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}/${var.s3_object}",
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "s3_ip_server"
  path        = "/"
  description = "Only Allow GetObject On Single File"

  policy = "${data.aws_iam_policy_document.s3_ip_server.json}"
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = "${aws_iam_role.tmp_lab_role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}


resource "aws_iam_instance_profile" "lab_instance_profile" {
  name = "tmp_lab_instance_profile"
  role = "${aws_iam_role.tmp_lab_role.name}"
}
