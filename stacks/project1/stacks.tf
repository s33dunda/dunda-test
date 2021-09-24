resource "spacelift_stack" "test-stack" {
  for_each            = local.stack_set
  administrative      = true
  autodeploy          = true
  branch              = "master"
  description         = "Shared cluster services (Datadog, Istio etc.)"
  name                = "Kubernetes core services"
  project_root        = local.project_root
  repository          = "dunda-test"
  terraform_workspace = each.key
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
