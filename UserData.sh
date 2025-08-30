#!/bin/bash

# Update currently installed software packages
echo "Updating installed packages..."
sudo yum update -y > /dev/null 2>&1

# Install Docker
echo "Installing Docker..."
sudo yum install docker -y > /dev/null 2>&1

# Adding Jenkins repo
echo "Adding Jenkins Repo..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y > /dev/null 2>&1

# Install Java
echo "Installing Java..."
sudo yum install java-21-amazon-corretto -y > /dev/null 2>&1

# Install Jenkins
echo "Installing Jenkins..."
sudo yum install jenkins -y > /dev/null 2>&1

# Add Docker to ec2-user and Jenkins to the Docker group
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

# Enable and start Jenkins service
echo "Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins 

# Enable and start Docker service
echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Install Git
echo "Installing Git..."
sudo yum install git -y > /dev/null 2>&1

# MOTD
echo "Welcome to DevOps Spot Instance." | sudo tee /etc/motd

echo "Bootstrap completed!"
