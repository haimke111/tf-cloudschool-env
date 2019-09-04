
// ???


terraform {
  backend "s3" {
    bucket = "cls1-terraform-class"
    key = "terraform.tfstate" // in modules
    dynamodb_table = "terraform-state-locking"
    region = "us-east-2"
  }
}

// ???

data "terraform_remote_state" "site" {
  backend = "s3"
  config = {
    bucket = "${var.terraform_bucket}"
    key = "${var.site_module_state_path}"
  }
}

module "clouschool-app" {
  source = "../"
  // ???
  chef_role = "${var.chef_role}"
  chef_resources_key = "${var.chef_resources_key}"
  file-name = "${var.file-name}"
  environment = "${var.environment}"
  terraform_bucket = "cls1-terraform-class"
  //vpc_id = "${aws_vpc.vpc.vpc_id}"
  private_subnets = "172.31.0.0/19"
  public_subnets  = "172.31.32.0/19"
  azs  =  "us-east-2c,us-east-2a"
  vpc_cidr = "${var.vpc_cidr}"
  region = "${var.region}"
  //terraform_bucket = "${var.terraform_bucket}"
  site_module_state_path = "${var.site_module_state_path}"
  instance_type = "t2.micro"
//  exchange_cluster_size = 2
}
