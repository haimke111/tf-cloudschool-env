data "template_file" "project-app_cloudconfig" {
  template = "${file("${path.module}/templates/project-app.cloudinit")}"
  ???
}

resource "aws_security_group" "project-app" {
  name = "${var.cluster_name}-sg"

  lifecycle {  # This is necessary to make terraform launch configurations work with autoscaling groups
    create_before_destroy = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  description = "${var.cluster_name}"
  
  ???
}


resource "aws_launch_configuration" "project-app_lc" {
  user_data = "${data.template_file.project-app_cloudconfig.rendered}"
   lifecycle {  # This is necessary to make terraform launch configurations work with autoscaling groups
    create_before_destroy = true
  }
  security_groups = [???]
  name_prefix = "${var.cluster_name}_lc"
  enable_monitoring = false
  
  ???
}
