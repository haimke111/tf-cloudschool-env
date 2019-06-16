// ??? whole file
variable "instance_type" {
  description = "instance type for project-app instances"
  default = "t2.small"
}

variable "ami" {
  description = "ami id for project-app instances"
  default = "ami-c80b0aa2"
}

variable "role" {
	default = "project-app-wrapper"
}

variable "cluster_name" {
	default = "project-app"
}

variable "project-app_cluster_size" {
  default = 2
}

variable "additional_sgs" {
  default = ""
}

variable "terraform_bucket" {
  description = <<EOS
S3 bucket with the remote state of the site module.
The site module is a required dependency of this module
EOS

}

variable "site_module_state_path" {
  description = <<EOS
S3 path to the remote state of the site module.
The site module is a required dependency of this module
EOS

}
