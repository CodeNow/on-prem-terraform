variable "environment" {}
variable "vpc_id" {}
variable "main_host_subnet_id" {}
variable "main_host_instance_type" {}
variable "dock_subnet_id" {}
variable "dock_instance_type" {}
variable "private_ip" {}
variable "github_org_id" {}
variable "lc_user_data_file_location" {}
variable "key_name" {}
variable "bastion_sg_id" {}

# Changing AMI forces new resource and will delete all everything in main host
# Ovewrite this variable with previous AMI if update is pushed
variable "main_host_ami" {
  default = "ami-5fa7353f" # singe-host-ami-build-v0.0.4
}

variable "dock_ami" {
  default = "ami-557dee35" # dock-ami-build-v.0.0.8
}

resource "aws_security_group" "main_host_sg" {
  name        = "${var.environment}-main-host-sg"
  description = "Allow all inbound traffic on all traffic over port 80"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${var.bastion_sg_id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dock_sg" {
  name        = "${var.environment}-dock-sg"
  description = "Allow all traffic from main host and between docks"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${var.bastion_sg_id}"]
  }

  ingress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    security_groups = ["${aws_security_group.main_host_sg.id}"]
  }

  ingress {
    from_port   = 8200
    to_port     = 8201
    protocol    = "tcp"
    security_groups = ["${aws_security_group.main_host_sg.id}"]
  }

  ingress {
    from_port   = 4242
    to_port     = 4242
    protocol    = "tcp"
    security_groups = ["${aws_security_group.main_host_sg.id}"]
  }

  ingress {
    from_port   = 29006
    to_port     = 29007
    protocol    = "tcp"
    security_groups = ["${aws_security_group.main_host_sg.id}"]
  }

  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    security_groups = ["${aws_security_group.main_host_sg.id}"]
  }

  ingress {
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    self        = true
  }

  ingress {
    from_port   = 6783
    to_port     = 6783
    protocol    = "udp"
    self        = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "main-instance" {
  ami                         = "${var.main_host_ami}"
  instance_type               = "${var.main_host_instance_type}"
  associate_public_ip_address = true
  private_ip                  = "${var.private_ip}"
  vpc_security_group_ids      = ["${aws_security_group.main_host_sg.id}"]
  subnet_id                   = "${var.main_host_subnet_id}"
  key_name                    = "${var.key_name}"

  tags {
    Name = "${var.environment}-main"
  }
}

resource "aws_launch_configuration" "dock_lc" {
  name_prefix     = "${var.environment}-dock-lc-"
  image_id        = "${var.dock_ami}"
  instance_type   = "${var.dock_instance_type}"
  user_data       = "${file("${var.lc_user_data_file_location}")}"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.dock_sg.id}"]

  root_block_device {
    volume_size = 10
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    snapshot_id = "snap-c77705e9"
    volume_size = 250
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "dock-auto-scaling-group" {
  name                      = "asg-${var.environment}-${var.github_org_id}"
  max_size                  = 30
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 4 # Start off with 0 and increase manually when main host is running
  vpc_zone_identifier       = ["${var.dock_subnet_id}"]
  launch_configuration      = "${aws_launch_configuration.dock_lc.name}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "org"
    value               = "${var.github_org_id}"
    propagate_at_launch = true
  }

  tag {
    key                 = "enviroment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "role"
    value               = "dock"
    propagate_at_launch = true
  }
}

# https://github.com/CodeNow/astral/blob/master/lib/shiva/tasks/asg.policy.scale-out.create.js#L49
resource "aws_autoscaling_policy" "dock_scaling_policy" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.dock-auto-scaling-group.name}"
  name                   = "scale-out"
  cooldown               = 600
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1
}

# https://github.com/CodeNow/astral/blob/master/lib/shiva/tasks/asg.policy.scale-out.create.js#L60
resource "aws_cloudwatch_metric_alarm" "dock_alarm" {
  alarm_name                = "${aws_autoscaling_group.dock-auto-scaling-group.name}-max-available-memory"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "Swarm Reserved Memory Maximum Available"
  namespace                 = "Runnable/Swarm"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "2.0"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.dock-auto-scaling-group.name}"
  }

  alarm_actions     = ["${aws_autoscaling_policy.dock_scaling_policy.arn}"]
}

resource "aws_sns_topic" "asg_events" {
  name = "asg-events-${var.environment}"
}

# https://github.com/CodeNow/astral/blob/master/lib/shiva/tasks/asg.policy.scale-out.create.js#L79
resource "aws_autoscaling_notification" "dock_scaling_notification" {
  group_names = [
    "${aws_autoscaling_group.dock-auto-scaling-group.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = "${aws_sns_topic.asg_events.arn}"
}

output "main_security_group_id" {
  value = "${aws_security_group.main_host_sg.id}"
}
