#!/bin/bash
# Update system
sudo yum update -y
sudo yum install -y git curl wget unzip python3 python3-pip

# Install Docker
sudo amazon-linux-extras install docker -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Setup Jenkins container
sudo mkdir -p /var/jenkins_home
sudo chown -R 1000:1000 /var/jenkins_home
sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home jenkins/jenkins:lts
echo "Jenkins Initial Admin Password:" >> /var/log/user-data.log
sudo cat /var/jenkins_home/secrets/initialAdminPassword >> /var/log/user-data.log


# Install CloudWatch Agent (for monitoring)
sudo yum install -y amazon-cloudwatch-agent

# MOTD
echo "Welcome to DevOps Spot Instance 🚀 (Docker + Jenkins preinstalled)" | sudo tee /etc/motd

echo "Bootstrap completed!"
