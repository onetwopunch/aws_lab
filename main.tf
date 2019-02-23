provider "aws" {
  region = "${var.region}"
}

data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.sh")}"
  vars = {
    region = "${var.region}"
    bucket = "${var.s3_bucket}"
    object = "${var.s3_object}"
  }
}

data "aws_ami" "amznlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20181114-x86_64-gp2"]
  }
}


resource "aws_key_pair" "deployer" {
  key_name   = "tmp-lab-deploy-key"
  public_key = "${var.public_key}"
}

resource "aws_lb" "lab" {
  enable_deletion_protection = false
  name                       = "tmp-lab-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.load_balancer.id}"]
  subnets                    = ["${aws_subnet.subnet.*.id}"]
}

resource "aws_lb_listener" "lab" {
  load_balancer_arn = "${aws_lb.lab.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lab.arn}"
  }
}

resource "aws_lb_target_group" "lab" {
  name        = "tmp-lab-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_launch_configuration" "amznlinux" {
  name = "AwsIpLabServer"
  instance_type = "t2.micro"
  image_id = "${data.aws_ami.amznlinux.id}"
  key_name = "${aws_key_pair.deployer.key_name}"
  user_data = "${data.template_file.userdata.rendered}"
  security_groups = ["${aws_security_group.instances.id}"]
  iam_instance_profile ="${aws_iam_instance_profile.lab_instance_profile.name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "lab" {
  name                 = "AwsLabIpServer"
  launch_configuration = "${aws_launch_configuration.amznlinux.name}"
  max_size             = "${var.desired_capacity}"
  min_size             = "${var.desired_capacity}"
  desired_capacity     = "${var.desired_capacity}"
  vpc_zone_identifier  = ["${aws_subnet.subnet.*.id}"]
  target_group_arns    = ["${aws_lb_target_group.lab.arn}"]
}
