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
    volume_size = 50
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
  desired_capacity          = 2 # Start off with 0 and increase manually when main host is running
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
}

output "main_security_group_id" {
  value = "${aws_security_group.main_host_sg.id}"
}
