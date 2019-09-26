data "template_file" "project-app_cloudconfig" {
  template = "${file("${path.module}/templates/project-app.cloudinit")}"
  vars = {
    chef_role = "${var.chef_role}",
    chef-resources_key = "${var.chef_resources_key}",
    file-name = "${var.file-name}"
  }
}
resource "aws_key_pair" "admin_key" {
//  key_name = "${var.environment}"
  public_key = "${file("${path.module}/keys/cloudschool1.pub")}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support = "${var.enable_dns_support}"
  tags = { Name = "${var.environment}-vpc" }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "internet gateway"
  }
}
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "route table"
  }
}
resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.r.id}"
}
resource "aws_security_group" "project-app" {
  name = "${var.cluster_name}-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  lifecycle {  # This is necessary to make terraform launch configurations work with autoscaling groups
    create_before_destroy = true
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  description = "${var.cluster_name}"

}
resource "aws_security_group" "project-app-elb" {
  name = "${var.cluster_name}-elb-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  lifecycle {  # This is necessary to make terraform launch configurations work with autoscaling groups
    create_before_destroy = true
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  description = "${var.cluster_name}"

}
resource "aws_security_group" "project-app-rds" {
  name = "${var.cluster_name}-rds-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  lifecycle {  # This is necessary to make terraform launch configurations work with autoscaling groups
    create_before_destroy = true
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  description = "${var.cluster_name}"

}
resource "aws_elb" "project-app-elb" {
  name               = "project-app-elb"
  //availability_zones = ["us-east-2a", "us-east-2b"]

  # access_logs {
  #   bucket        = "foo"
  #   bucket_prefix = "bar"
  #   interval      = 60
  # }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  #instances                   = ["${aws_instance.foo.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  security_groups = flatten([aws_security_group.project-app-elb.id])
  subnets = flatten([aws_subnet.private.0.id])

  tags = {
    Name = "project-app-elb"
  }
}
resource "aws_db_instance" "project-app-rds" {
  depends_on = ["aws_internet_gateway.gw"]
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "Aa123456"
  publicly_accessible  = true
  skip_final_snapshot  = true
//  parameter_group_name = "default.mysql5.7"
//  security_group_names = flatten([aws_security_group.project-app-rds.id])
  vpc_security_group_ids = flatten([aws_security_group.project-app-rds.id])
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
//  provisioner "local-exec" {
//    command = 
//  }
}
resource "null_resource" "setup_db" {
  depends_on = ["aws_db_instance.project-app-rds"] #wait for the db to be ready
  provisioner "local-exec" {
    command = "mysql -u${aws_db_instance.project-app-rds.username} -p${var.my_db_password} -h${aws_db_instance.project-app-rds.address} < db_provision.sql"
  }
}
resource "aws_launch_configuration" "project-app_lc" {
  user_data = "${data.template_file.project-app_cloudconfig.rendered}"
   lifecycle {  # This is necessary to make terraform launch configurations work with autoscaling groups
    create_before_destroy = true
  }
  security_groups = flatten([aws_security_group.project-app.id])
  name_prefix = "${var.cluster_name}_lc"
  enable_monitoring = false
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.admin_key.key_name}"

}
resource "aws_autoscaling_group" "project_app_asg" {
  name                      = "project_app_asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  //placement_group           = "${aws_placement_group.test.id}"
  launch_configuration      = "${aws_launch_configuration.project-app_lc.name}"
  vpc_zone_identifier       = ["${aws_subnet.public.0.id}"]
  load_balancers            = flatten([aws_elb.project-app-elb.name])

#   initial_lifecycle_hook {
#     name                 = "foobar"
#     default_result       = "CONTINUE"
#     heartbeat_timeout    = 2000
#     lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

#     notification_metadata = <<EOF
# {
#   "foo": "bar"
# }
# EOF

#     notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
#     role_arn                = "arn:aws:iam::123456789012:role/S3Access"
#   }

  # tag {
  #   key                 = "foo"
  #   value               = "bar"
  #   propagate_at_launch = true
  # }

  # timeouts {
  #   delete = "15m"
  # }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = false
  }
}

