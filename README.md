This repo will create all the prerequisite resouces before using kubectl to install aws-load-balancer-controller:
- IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf
- IAM role with OIDC trust policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf
- Kubernetes service account in the kube-system namespace for the AWS Load Balancer Controller and annotate the Kubernetes service account with the IAM role

You will still need to use kubectl to deploy cert manager and the load balancer controller

cert-manager:
```
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
```

controller:
```
curl -Lo v2_4_7_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_full.yaml
sed -i.bak -e '561,569d' ./v2_4_7_full.yaml
#Replace your-cluster-name in the Deployment spec section of the file with the name of your cluster by replacing my-cluster with the name of your cluster.
sed -i.bak -e 's|your-cluster-name|my-cluster|' ./v2_4_7_full.yaml
kubectl apply -f v2_4_7_full.yaml
```

Reference:
https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html