This repo will create all the prerequisite resouces before using kubectl to install aws-load-balancer-controller:
- IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf
- IAM role with OIDC trust policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf
- Kubernetes service account in the kube-system namespace for the AWS Load Balancer Controller and annotate the Kubernetes service account with the IAM role

Reference:
https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html