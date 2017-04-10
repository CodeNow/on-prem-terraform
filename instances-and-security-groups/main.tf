variable "environment" {}
variable "vpc_id" {}
variable "main_host_subnet_id" {}
variable "dock_subnet_id" {}
variable "private_ip" {}
variable "github_org_id" {}
variable "lc_user_data_file_location" {}
variable "key_name" {}
variable "bastion_sg_id" {}

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
}

resource "aws_security_group" "dock_sg" {
  name        = "${var.environment}-dock-sg"
  description = "Allow all traffic to main host and between docks"
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
}

resource "aws_instance" "main-instance" {
  ami                         = "ami-6426a804" # singe-host-ami-build-v0.0.1
  instance_type               = "t2.xlarge"
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
  name_prefix   = "${var.environment}-dock-lc-"
  image_id      = "ami-1c5dcc7c"
  instance_type = "t2.large"
  user_data     = "${file("${var.lc_user_data_file_location}")}"
  key_name      = "${var.key_name}"

  ebs_block_device {
    device_name = "docker-ebs"
    snapshot_id = "snap-c77705e9"
    volume_size = 30
  }
}

resource "aws_autoscaling_group" "dock-auto-scaling-group" {
  name                      = "asg-${var.environment}-${var.github_org_id}"
  max_size                  = 5
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 0 # Start off with 0 and increase manually when main host is running
  vpc_zone_identifier       = ["${var.dock_subnet_id}"]
  launch_configuration      = "${aws_launch_configuration.dock_lc.name}"
}
