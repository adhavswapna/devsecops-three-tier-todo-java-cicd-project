Three-Tier Todo Java CI/CD Project

This repository contains the setup and configuration files for deploying a three-tier Todo application using Java, Jenkins, Terraform, AWS EKS, and other related tools.
Setup Instructions
1. Clone the Repository

bash

git clone https://github.com/adhavswapna/three-tier-todo-java-cicd-project.git
cd three-tier-todo-java-cicd-project

2. Setting up Jenkins and Terraform on EC2

Navigate to the Jenkins Terraform files directory:

bash

cd jenkins-terraform-files

Initialize Terraform, plan, and apply the infrastructure:

bash

terraform init
terraform plan
terraform apply

Ensure install-tools.sh is updated with installation details for Jenkins, Terraform, EKSCTL, kubectl, Trivy, AWS CLI, Docker, and SonarQube.
3. Access Jenkins and SonarQube

On your EC2 instance, access Jenkins on port 8080 and SonarQube on port 9000 using the public IP address.
4. Create EKS Cluster

bash

eksctl create cluster --name three-tier-cicd-cluster --region us-east-1

5. Install AWS Load Balancer Controller

Download IAM policy configuration:

bash

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

Create IAM policy:

bash

aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

Associate IAM OIDC provider:

bash

eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster three-tier-cicd-cluster --approve

Create IAM service account for AWS Load Balancer Controller:

bash

eksctl create iamserviceaccount \
  --cluster=three-tier-cicd-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::11111111111:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

Install AWS Load Balancer Controller using Helm:

bash

helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=three-tier-cicd-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1

Verify AWS Load Balancer Controller deployment:

bash

kubectl get deployment -n kube-system aws-load-balancer-controller

6. Configure kubectl

Update kubeconfig to access the EKS cluster:

bash

aws eks --region us-east-1 update-kubeconfig --name three-tier-cicd-cluster

7. Install ArgoCD

Create a namespace for ArgoCD:

bash

kubectl create namespace argocd

Apply ArgoCD installation manifest:

bash

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Patch ArgoCD server service to use LoadBalancer:

bash

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

Retrieve ArgoCD initial admin password:

bash

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

8. Clean Up(in case required and re-work)

To delete everything created:

bash

eksctl delete cluster --name three-tier-cicd-cluster --region us-east-1

aws cloudformation delete-stack --stack-name eksctl-three-tier-cicd-cluster-cluster --region us-east-1

eksctl delete iamserviceaccount \
  --cluster=three-tier-cicd-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller

helm uninstall aws-load-balancer-controller -n kube-system








