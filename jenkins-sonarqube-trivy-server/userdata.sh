#!/bin/bash
set -euo pipefail

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl git wget

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | tee /etc/apt/keyrings/jenkins.asc > /dev/null
chmod 0644 /etc/apt/keyrings/jenkins.asc
echo "deb [signed-by=/etc/apt/keyrings/jenkins.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y fontconfig openjdk-21-jre jenkins
install -d -m 0755 /etc/systemd/system/jenkins.service.d
cat > /etc/systemd/system/jenkins.service.d/java.conf <<'EOF'
[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"
Environment="JENKINS_JAVA_CMD=/usr/lib/jvm/java-21-openjdk-amd64/bin/java"
EOF
systemctl daemon-reload
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
