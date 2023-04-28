locals {
  aws_alb_ingress_controller_docker_image = "public.ecr.aws/eks/aws-load-balancer-controller:v${var.aws_load_balancer_controller_version}"
  aws_load_balancer_controller_version    = var.aws_load_balancer_controller_version
  aws_vpc_id                              = data.aws_vpc.target.id
  aws_region_name                         = data.aws_region.current.name
  aws_iam_path_prefix                     = var.aws_iam_path_prefix == "" ? null : var.aws_iam_path_prefix
}

data "aws_eks_cluster" "target" {
  name = var.k8s_cluster_name
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.target.name
}

provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  region                   = var.aws_region_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.target.name]
  }
}

data "aws_vpc" "target" {
  id = data.aws_eks_cluster.target.vpc_config[0].vpc_id
}

data "aws_region" "current" {
  name = var.aws_region_name
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.target.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.k8s_namespace}:aws-load-balancer-controller"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.target.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.target.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "this" {
  name        = "${var.aws_resource_name_prefix}${var.k8s_cluster_name}-load-balancer-controlle-role"
  description = "Permissions required by the Kubernetes AWS Load Balancer controller to do it's job."
  path        = local.aws_iam_path_prefix

  tags = var.aws_tags

  force_detach_policies = true

  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role.json
}

resource "aws_iam_policy" "this" {
  name        = "${var.aws_resource_name_prefix}${var.k8s_cluster_name}-load-balancer-policy"
  description = "Permissions that are required to manage AWS Elastic Load Balancers."
  path        = local.aws_iam_path_prefix
  policy      = file("controller_policy.json")
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.k8s_namespace
    annotations = {
      # This annotation is only used when running on EKS which can
      # use IAM roles for service accounts.
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
    labels = {
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}
