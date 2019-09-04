// ??? whole file
variable "environment" {
  description = "This is mainly used to set various ideintifiers and prefixes/suffixes"
}
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
variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default = true
}
variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default = true
}
variable "azs" { }
variable "private_subnets" {
  description = "IP prefix of private (vpc only routing) subnets"
  default = "172.31.0.0/19"
}

variable "public_subnets" {
  description = "IP prefix of public (internet gw route) subnet"
  default = "172.31.32.0/19"
}
variable "vpc_cidr" {
  type = "string"
    description = "IP prefix of main vpc"
    default = "172.31.0.0/18"
}
variable "region" {
  type = "string"
  default = "us-east-2"
}
variable "chef_role" {
    type = "string"
}
variable "chef_resources_key" {
  type = "string"
}

variable "file-name" {
  type = "string"
}