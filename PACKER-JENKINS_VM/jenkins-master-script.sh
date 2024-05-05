#!/bin/bash

# Function to check if Jenkins service is running
jenkins_installed() {
    sudo systemctl is-active --quiet jenkins
}

# Check the operating system
echo "Checking the operating system..."
OS=$(awk -F= '/PRETTY_NAME/{gsub(/"/,"",$2); print $2; exit}' /etc/os-release)

# Check if Jenkins is already installed
if jenkins_installed; then
    echo "Jenkins is already installed."
    exit 1
fi

# Install required packages
echo "Installing required packages..."
case $OS in
    "Ubuntu")
        sudo apt update
        sudo apt install -y \
            ca-certificates \
            curl \
            wget \
            apt-utils \
            vim \
            openssh-client \
            openssh-server \
            python3 \
            nodejs \
            build-essential \
            npm \
            ansible \
            htop \
            watch \
            python3-pip \
            git \
            make \
            postgresql \
            python3-pip \
            openssl \
            rsync \
            jq \
            postgresql-client \
            mariadb-client \
            mysql-client \
            unzip \
            tree \
            default-jdk \
            default-jre \
            maven \
            gnupg \
            software-properties-common
        ;;
    "CentOS"|"Amazon")
        sudo yum install -y \
            epel-release \
            curl \
            wget \
            vim \
            openssh-clients \
            openssh-server \
            python3 \
            nodejs \
            gcc \
            gcc-c++ \
            npm \
            ansible \
            htop \
            watch \
            python3-pip \
            git \
            make \
            postgresql \
            python3-pip \
            openssl \
            rsync \
            jq \
            postgresql \
            mariadb \
            mysql \
            unzip \
            tree \
            java-17-openjdk-devel \
            maven \
            gnupg \
            which
        ;;
    *)
        echo "Unsupported operating system."
        exit 1
        ;;
esac

# Install Jenkins
echo "Installing Jenkins..."
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -   # Ubuntu only
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'   # Ubuntu only
sudo apt update   # Ubuntu only
sudo apt install -y jenkins   # Ubuntu only

# Start and enable Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Configure firewall to allow port 8080
echo "Configuring firewall..."
sudo ufw allow 8080/tcp >/dev/null 2>&1   # Ubuntu only

echo "Jenkins installation completed."
