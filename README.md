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

Installation of sonarqube steps:
How to Install Sonarqube in Ubuntu Linux
Prerequsites
Virtual Machine running Ubuntu 22.04 or newer

Install Postgresql 15
sudo apt update
sudo apt upgrade

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null

sudo apt update
sudo apt-get -y install postgresql postgresql-contrib
sudo systemctl enable postgresql
Create Database for Sonarqube
sudo passwd postgres
su - postgres

createuser sonar
psql 
ALTER USER sonar WITH ENCRYPTED password 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
grant all privileges on DATABASE sonarqube to sonar;
\q

exit
Install Java 17
sudo bash

apt install -y wget apt-transport-https
mkdir -p /etc/apt/keyrings

wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc

echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

apt update
apt install temurin-17-jdk
update-alternatives --config java
/usr/bin/java --version

exit 
Increase Limits
sudo vim /etc/security/limits.conf
Paste the below values at the bottom of the file

sonarqube   -   nofile   65536
sonarqube   -   nproc    4096
sudo vim /etc/sysctl.conf
Paste the below values at the bottom of the file

vm.max_map_count = 262144
Reboot to set the new limits

sudo reboot
Install Sonarqube
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
sudo apt install unzip
sudo unzip sonarqube-9.9.0.65466.zip -d /opt
sudo mv /opt/sonarqube-9.9.0.65466 /opt/sonarqube
sudo groupadd sonar
sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R
Update Sonarqube properties with DB credentials

sudo vim /opt/sonarqube/conf/sonar.properties
Find and replace the below values, you might need to add the sonar.jdbc.url

sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
Create service for Sonarqube

sudo vim /etc/systemd/system/sonar.service
Paste the below into the file

[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
Start Sonarqube and Enable service

sudo systemctl start sonar
sudo systemctl enable sonar
sudo systemctl status sonar


Access the Sonarqube UI
http://<IP>:9000


login sonarqube with admin both username and password will be admin
give new username and password, 
Administration - users - security - click Tokens - generate token - name and done
copy sonarqube token and save it in somewhere
Administration - webhooks - create - url- jenkins url/jenkins/webhooks - create
then,
projects - manually - give name backend-three-tier - click locally - click existing token and paste created token - continue - click maven and other you will get script copy entire script and paste it on backend-jenkinsfile under sonarqube and then click on create project
same steps use for frontend-three-tier but after clicked locally select other and linux and then copy entire script and past it on jenkinsfile frontend-jenkinsfile and then click create project













