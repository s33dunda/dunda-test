resource "aws_cloudwatch_log_group" "yada" {
  name = "Yada-yada-${var.cp_tf_var}-${terraform.workspace}"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}

variable "cp_tf_var" {}

provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "2u-terraform-imp-dev"
    region = "us-west-2"
    key    = "dunda-test/cloudwatch_log_groups"
  }

}
resource "aws_iam_user" "lb" {
  count = var.cp_tf_var == "test4" ? 1 : 0
  name  = "loadbalancer"
  path  = "/system/"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_access_key" "lb" {
  count = var.cp_tf_var == "test4" ? 1 : 0
  user  = aws_iam_user.lb[count.index].name
}
