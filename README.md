Devsecops Three-Tier Todo Java CI/CD Project, 
Three-Tier architecture on AWS using Kubernetes, DevOps best practices, 
deploying, securing, and monitoring a scalable application environment.



1. IAM User Setup: Create an IAM user on AWS with the necessary permissions
to facilitate deployment and management activities.
2. Infrastructure as Code (IaC): Use Terraform and AWS CLI to set up the
Jenkins server (EC2 instance) on AWS.
3. Jenkins Server Configuration: Install and configure essential tools on the
Jenkins server, including Jenkins itself, Docker, Sonarqube, Terraform,
Kubectl, AWS CLI, and Trivy.
4. EKS Cluster Deployment: Utilize eksctl commands to create an Amazon EKS
cluster, a managed Kubernetes service on AWS.
5. Load Balancer Configuration: Configure AWS Application Load Balancer
(ALB) for the EKS cluster.
6. Docker Repositories: Create repositories on Docker hub for both frontend and
backend Docker images on Amazon Elastic Container Registry (ECR).
7. ArgoCD Installation: Install and set up ArgoCD for continuous delivery and
GitOps.
8. Sonarqube Integration: Integrate Sonarqube for code quality analysis in the
DevSecOps pipeline.
9. Jenkins Pipelines: Create Jenkins pipelines for deploying backend and
frontend code to the EKS cluster.
10. Monitoring Setup: Implement monitoring for the EKS cluster using Helm,
Prometheus, and Grafana.
11. ArgoCD Application Deployment: Use ArgoCD to deploy the Three-Tier
application, including database, backend, frontend, and ingress components.
12. DNS Configuration: Configure DNS settings to make the application
Step 1: We need to create an IAM user and generate the AWS Access
key
Create a new IAM User on AWS and give it to the AdministratorAccess for testing
purposes (not recommended for your Organization's Projects)
Advanced End-to-End DevSecOps Kubernetes Three-T... https://blog.stackademic.com/advanced-end-to-end-de...
3 of 68accessible via custom subdomains.
13. Data Persistence: Implement persistent volume and persistent volume claims
for database pods to ensure data persistence.
Click on Create user
Provide the name to your user and click on Next.
accessible via custom subdomains.
13. Data Persistence: Implement persistent volume and persistent volume claims
for database pods to ensure data persistence.
14. Conclusion and Monitoring: Conclude the project by summarizing key
achievements and monitoring the EKS cluster’s performance using Grafana.
Prerequisites:
Before starting the project, ensure you have the following prerequisites:
• An AWS account with the necessary permissions to create resources.
• Terraform and AWS CLI installed on your local machine.
• Basic familiarity with Kubernetes, Docker, Jenkins, and DevOps principles.

CREATE IAM USER
Go to the AWS IAM Service and click on Users.
Click on Create user
Provide the name to your user and click on Next.
Select the Attach policies directly option and search for AdministratorAccess
then select it.
Click on the Next.
Click on Create user
Now, Select your created user then click on Security credentials and generate
access key by clicking on Create access key.
Select the Command Line Interface (CLI) then select the checkmark for the
confirmation and click on Next
Provide the Description and click on the Create access key.
Here, you will see that you got the credentials and also you can download the CSV
file for the future.



This repository contains the setup and configuration files for deploying a three-tier Todo application using Java, Jenkins, Terraform, AWS EKS, and other related tools.
Setup Instructions
1. Clone the Repository



git clone https://github.com/adhavswapna/three-tier-todo-java-cicd-project.git
cd three-tier-todo-java-cicd-project

2. Setting up Jenkins and Terraform on EC2

Navigate to the Jenkins Terraform files directory:



cd jenkins-terraform-files
Initialize Terraform, plan, and apply the infrastructure:



terraform init
terraform plan
terraform apply

Ensure install-tools.sh is updated with installation details for Jenkins, Terraform, EKSCTL, kubectl, Trivy, AWS CLI, Docker, and SonarQube.


On your EC2 instance, access Jenkins on port 8080 
Initial Jenkins Setup

    Unlock Jenkins:
        Open a terminal and run:

        bash

        sudo cat /var/lib/jenkins/secrets/initialAdminPassword

        Copy the password and use it to unlock Jenkins through the web interface.

    Customize Jenkins:
        Click on "Install suggested plugins."

    Create First Admin User:
        Follow the prompts to create the first admin user.

Plugin Installation

    Manage Jenkins > Manage Plugins > Available Plugins:
        Search and install the following plugins:
            Pipeline: Stage View
            AWS Credentials
            Pipeline: AWS Steps
            Docker
            Docker Commons
            Docker Pipeline
            Docker API
            docker-build-step
            SonarQube Scanner
            OWASP Dependency-Check
            Eclipse Temurin Installer
            NodeJS

Tool Configuration

    Manage Jenkins > Global Tool Configuration:
        JDK:
            Add JDK, name it OpenJDK-17, check "Install automatically," and select OpenJDK 17.
        Git:
            Check "Install automatically."
        Maven:
            Add Maven, name it Maven 3.8.7, check "Install automatically," and select version 3.8.7.
        SonarQube Scanner:
            Add SonarQube Scanner, name it sonar-scanner.
        OWASP Dependency-Check:
            Add OWASP Dependency-Check, name it owasp dp-check.

Credential Configuration

    Manage Jenkins > Manage Credentials > Global > Add Credentials:
        AWS Credentials:
            Kind: Username with password
            ID: aws-key
            Description: aws-key
            Username: ACCESS KEY
            Password: SECRET ACCESS KEY
        SonarQube:
            Kind: Secret text
            ID: sonar-token
            Description: sonar-token
            Secret: [Your SonarQube token]
        GitHub (Token only):
            Kind: Secret text
            ID: github-token
            Description: github-token
            Secret: [Your GitHub token]
        GitHub (Username and Token):
            Kind: Username with password
            ID: github-psw
            Description: github-psw
            Username: [Your GitHub username]
            Password: [Your GitHub token]
        Docker:
            Kind: Username with password
            ID: docker-cred
            Description: docker-cred
            Username: [Your Docker username]
            Password: [Your Docker password]

SonarQube Configuration

    Manage Jenkins > Configure System:
        SonarQube servers:
            Add a SonarQube server, name it sonar-server.
            Server URL: [Your SonarQube server URL]
            Server authentication token: Select sonar-token from the credentials dropdown.

Environment Variables and Tools for Pipeline

    Environment Variables:
        GIT_BRANCH: Default is main.
        GIT_USER_NAME: Default is your username.
        GIT_REPO_NAME: Default is github repo name.
        DOCKER_REPO_NAME: Default is dockerhub repo name.
        SONARQUBE_SCANNER_HOME: sonar-scanner.
        DOCKER_CREDENTIAL: docker-cred.
        SONARQUBE_TOKEN: sonar-token.
        ODC_HOME: owasp dp-check.
        GITHUB_TOKEN: github-token.

    Tools:
        JDK: OpenJDK 17
        Maven: Maven 3.8.7



3. Create EKS Cluster
eksctl create cluster --name three-tier-cicd-cluster --region us-east-1


4. Install AWS Load Balancer Controller

Download IAM policy configuration:
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json


Create IAM policy:

aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

Associate IAM OIDC provider:



eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster three-tier-cicd-cluster --approve

Create IAM service account for AWS Load Balancer Controller:



eksctl create iamserviceaccount \
  --cluster=three-tier-cicd-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::11111111111:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

Install AWS Load Balancer Controller using Helm:



helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=three-tier-cicd-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1

Verify AWS Load Balancer Controller deployment:

kubectl get deployment -n kube-system aws-load-balancer-controller


5. Configure kubectl

Update kubeconfig to access the EKS cluster:

aws eks --region us-east-1 update-kubeconfig --name three-tier-cicd-cluster



6. Clean Up(in case required and re-work)
To delete everything created:
eksctl delete cluster --name three-tier-cicd-cluster --region us-east-1

aws cloudformation delete-stack --stack-name eksctl-three-tier-cicd-cluster-cluster --region us-east-1

eksctl delete iamserviceaccount \
  --cluster=three-tier-cicd-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller

helm uninstall aws-load-balancer-controller -n kube-system

7. Installation of sonarqube steps(I have already mentioned on install-tools.sh file to fetch docker image of sonarqube but for manually installation of sonarqube follow the below steps):

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
sudo apt install -y wget apt-transport-https
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


8. PROMETHEUS AND GRAFANA
helm repo add stable https://charts.helm.sh/stable

Install the prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
kubectl get svc

we need to change service status as load balancer

Edit the stable-kube-prometheus-sta-prometheus service
kubectl edit svc stable-kube-prometheus-sta-prometheus


Edit the stable-grafana service
kubectl edit svc stable-grafana
kubectl get svc

go to aws consoles load balancer
copy prometheus load balancer and paste it on browser 

Click on Status and select Target.
You will see a lot of Targets

Now, access your Grafana Dashboard
Copy the ALB DNS of Grafana and paste it into your favorite browser.
The username will be admin and the password will be prom-operator for your
Grafana LogIn.
Now, click on Data Source
Select Prometheus
In the Connection, paste your <Prometheus-LB-DNS>:9090.
If the URL is correct, then you will see a green notification Click on Save & test.
Now, we will create a dashboard to visualize our Kubernetes Cluster Logs.
Click on Dashboard.
Once you click on Dashboard. You will see a lot of Kubernetes components
monitoring.
Let’s try to import a type of Kubernetes Dashboard.
Click on New and select Import
Provide 6417 ID and click on Load
Note: 6417 is a unique ID from Grafana which is used to Monitor and visualize
Kubernetes Data
Select the data source that you have created earlier and click on Import.


Step : deploy our Three-Tier Application using ArgoCD.

9. Install ArgoCD

Create a namespace for ArgoCD:



kubectl create namespace argocd

Apply ArgoCD installation manifest:



kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Patch ArgoCD server service to use LoadBalancer:



kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

Retrieve ArgoCD initial admin password:



kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


application for the backend.
click on CREATE APPLICATION.
paste github repository In the Path, provide the location where your Manifest files are presented

then we will create an application for the frontend.
Select the same repository of github, In the Path, provide the location where your Manifest files are presented and Click on CREATE.
then we will create an
application for the ingress.
paste github repository
In the Path, provide the location where your Manifest files are presented and Click on CREATE.
Once your Ingress application is deployed. It will create an Application Load Balancer
You can check out the load balancer ow aws  Now, Copy the ALB-DNS and go to your Domain Provider and create domain name
Go to DNS and add a CNAME type with hostname backend then add your ALB in
the Answer and click on Save
• Implemented monitoring with Helm, Prometheus, and Grafana.
Finally paste subdomain on browser to get our Application 










