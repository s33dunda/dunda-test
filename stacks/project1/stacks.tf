resource "spacelift_stack" "test-stack" {
  for_each            = local.stack_set
  administrative      = true
  autodeploy          = false
  branch              = "master"
  description         = "Stack for workspace ${each.key}"
  name                = each.key
  project_root        = local.project_root
  repository          = "dunda-test"
  manage_state        = false
  terraform_workspace = each.key
  before_plan = [
    "export FILE=\"cp_tfvarfiles/$(terraform workspace show).cp.tfvars\"",
    "if [ -f \"$FILE\" ]; then export TF_CLI_ARGS=-var-file=\"cp_tfvarfiles/$(terraform workspace show).cp.tfvars\"; fi",
    # "export FILE=\"tfvarfiles/$(terraform workspace show).tfvars\"",
    # "if [ -f \"$FILE\" ]; then export TF_CLI_ARGS=-var-file=\"cp_tfvarfiles/$(terraform workspace show).cp.tfvars\"; fi"
  ]
}

resource "spacelift_aws_role" "k8s-core" {
  for_each = local.stack_set
  stack_id = spacelift_stack.test-stack[each.key].id
  role_arn = "arn:aws:iam::102456302505:role/Implementation-Team-Sandbox"
}

resource "spacelift_run" "this" {
  for_each = local.stack_set
  stack_id = spacelift_stack.test-stack[each.key].id

  keepers = {
    terraform_workspace = each.key
  }
}

resource "spacelift_policy_attachment" "slack" {
  for_each  = local.stack_set
  policy_id = spacelift_policy.slack.id
  stack_id  = spacelift_stack.test-stack[each.key].id
}

resource "spacelift_policy" "slack" {
  name = "test-slack"
  type = "ACCESS"
  body = <<EOF
  package spacelift

  write {
    input.slack.channel.name = "spacelift-chat"
  }

  write {
    input.slack.user.display_name = "dunda"
  }

  read {
    input.slack.channel.name = "spacelift-chat"
  }
EOF
}

locals {
  project_root  = "/${reverse(split("/", path.cwd))[0]}"
  cp_tfvarfiles = fileset("../..${local.project_root}/cp_tfvarfiles", "*.cp.tfvars")
  stack_set     = toset([for file in local.cp_tfvarfiles : split(".", file)[0]])
}

terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}
