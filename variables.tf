variable "k8s_cluster_type" {
  description = "Can be set to `vanilla` or `eks`. If set to `eks`, the Kubernetes cluster will be assumed to be run on EKS which will make sure that the AWS IAM Service integration works as supposed to."
  type        = string
  default     = "eks"
}

variable "k8s_cluster_name" {
  description = "Name of the Kubernetes cluster. This string is used to contruct the AWS IAM permissions and roles. If targeting EKS, the corresponsing managed cluster name must match as well."
  type        = string
  default     = "Cluster-BD"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace to deploy the AWS Load Balancer Controller into."
  type        = string
  default     = "kube-system"
}

variable "k8s_replicas" {
  description = "Amount of replicas to be created."
  type        = number
  default     = 1
}


variable "k8s_pod_annotations" {
  description = "Additional annotations to be added to the Pods."
  type        = map(string)
  default     = {}
}

variable "k8s_pod_labels" {
  description = "Additional labels to be added to the Pods."
  type        = map(string)
  default     = {}
}

variable "aws_iam_path_prefix" {
  description = "Prefix to be used for all AWS IAM objects."
  type        = string
  default     = ""
}

variable "aws_vpc_id" {
  description = "ID of the Virtual Private Network to utilize. Can be ommited if targeting EKS."
  type        = string
  default     = null
}

variable "aws_region_name" {
  description = "ID of the Virtual Private Network to utilize. Can be ommited if targeting EKS."
  type        = string
  default     = "us-east-2"
}

variable "aws_resource_name_prefix" {
  description = "A string to prefix any AWS resources created. This does not apply to K8s resources"
  type        = string
  default     = "eks-"
}

variable "aws_tags" {
  description = "Common AWS tags to be applied to all AWS objects being created."
  type        = map(string)
  default     = {}
}

variable "aws_load_balancer_controller_version" {
  description = "The AWS Load Balancer Controller version to use. See https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases for available versions"
  type        = string
  default     = "2.4.7"
}
