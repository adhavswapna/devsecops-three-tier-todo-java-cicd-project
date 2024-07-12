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

