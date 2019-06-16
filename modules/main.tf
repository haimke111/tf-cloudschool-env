
// ???

terraform {
  backend "s3" {
    bucket = "cloudschool-tf-state"
    key = "env/terraform.tfstate" // in modules
    dynamodb_table = "tf-cloudschool-env"
    region = "us-east-1"
  }
}

// ???
data "terraform_remote_state" "site" {
  backend = "s3"
  config {
    bucket = "${var.terraform_bucket}"
    key = "${var.site_module_state_path}"
  }
}

module "clouschool-app" {
  source = "../"
  // ???
  terraform_bucket = "${var.terraform_bucket}"
  site_module_state_path = "${var.site_module_state_path}"
  instance_type = "t2.micro"
  exchange_cluster_size = 2
}
