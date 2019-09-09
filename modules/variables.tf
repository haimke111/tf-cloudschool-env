variable "environment" {
  description = "This is mainly used to set various ideintifiers and prefixes/suffixes"
}
variable "vpc_cidr" {
  type = "string"
    description = "IP prefix of main vpc"
    default = "172.31.0.0/18"
}
variable "terraform_bucket" {
  description = <<EOS
S3 bucket with the remote state of the site module.
The site module is a required dependency of this module
EOS
  default = "cls1-terraform-class"

}

variable "site_module_state_path" {
  description = <<EOS
S3 path to the remote state of the site module.
The site module is a required dependency of this module
EOS
  default = "1.txt"
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
variable "private_subnets" {
  description = "IP prefix of private (vpc only routing) subnets"
  default = ["172.31.0.0/20","172.31.16.0/20"]
}

variable "public_subnets" {
  description = "IP prefix of public (internet gw route) subnet"
  default = "172.31.32.0/19"
}