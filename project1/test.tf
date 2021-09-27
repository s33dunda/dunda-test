resource "aws_cloudwatch_log_group" "yada" {
  name = "Yada-${var.cp_tf_var}-${terraform.workspace}"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}

variable "cp_tf_var" {}

provider "aws" {
  region = "us-west-2"
}
