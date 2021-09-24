# Create an AMI that will start a machine whose root device is backed by
# an EBS volume populated from a snapshot. It is assumed that such a snapshot
# already exists with the id "snap-xxxxxxxx".
resource "aws_ami" "example" {
  name                = "${var.cp_tf_var}-${terraform.workspace}"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"
}

variable "cp_tf_var" {}

provider "aws" {
  region = "us-west-2"
}
