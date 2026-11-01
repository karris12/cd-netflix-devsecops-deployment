#!/bin/bash
set -euo pipefail

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl git wget

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /etc/apt/keyrings/jenkins.asc > /dev/null
chmod 0644 /etc/apt/keyrings/jenkins.asc
echo "deb [signed-by=/etc/apt/keyrings/jenkins.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y fontconfig openjdk-17-jre jenkins
systemctl enable --now jenkins

DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io
usermod -aG docker ubuntu
usermod -aG docker jenkins
systemctl enable --now docker
systemctl restart jenkins

wget -O /tmp/trivy.deb https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb
DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/trivy.deb
rm /tmp/trivy.deb

# Run SonarQube image
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
