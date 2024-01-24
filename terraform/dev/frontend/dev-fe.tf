terraform {
    backend "s3" {
        bucket = "tf-backend-leforest"
        key = "states/leforest"
        region = "us-east-1"
    }
}
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "us-east-2"
    default_tags {
        tags = {
            Name = "create-by-terraform-demo-need-tag"
        }
    }
}
module "frontend" {
    source = "../../modules/frontend"

    network_address_space = "${var.network_address_space}"

    env_name = "${var.env_name}"

    subnet_count = "${var.subnet_count}"

}