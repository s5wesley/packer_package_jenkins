#!/bin/bash

# Check if the user is root
if [[ $(id -u) -ne 0 ]]; then 
    echo "Sorry, you need to be root"
    exit 1 
fi 

# Checking OS type 
TYPE=$(awk -F= '/^ID=/{print $2}' /etc/*rel* | head -n1)

if [[ $TYPE != "ubuntu" ]]; then 
    echo "Sorry, this script can only work on Ubuntu"
    exit 1 
fi 

echo "Installing Jenkins agent... please wait"
apt update -y
apt install -y \
    tree \
    curl \
    vim \
    wget \
    ansible \
    openjdk-17-jdk \
    ansible-lint \
    maven \
    git \
    unzip \
    openssl \
    sshpass \
    gnupg

# Additional installations and configurations for Jenkins agent...
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
apt-get install -y tzdata
dpkg-reconfigure --frontend noninteractive tzdata

git clone https://github.com/ahmetb/kubectx /usr/local/kubectx
ln -s /usr/local/kubectx/kubectx /usr/local/bin/kubectx
ln -s /usr/local/kubectx/kubens /usr/local/bin/kubens

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

useradd jenkins -m -d /home/jenkins -s /bin/bash
useradd ansible -m -d /home/ansible -s /bin/bash
echo 'jenkins ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jenkins
echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

apt-get remove docker docker-engine docker.io containerd runc -y
apt-get update

apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin

apt update
apt install -y \
    apt-transport-https \
    ca-certificates \
    dnsutils \
    htop \
    iftop \
    iotop \
    iperf \
    iputils-ping \
    jq \
    less \
    locales \
    ltrace \
    man-db \
    manpages \
    mosh \
    mtr \
    netcat \
    nethogs \
    nfs-common \
    pass \ 
    psmisc \
    python3-apt \
    python3-docker \
    rkhunter \
    rsync \
    screen \
    ssl-cert \
    strace \
    tcpdump \
    time \
    traceroute \
    unhide \
    unzip \
    uuid-runtime 

chmod 666 /var/run/docker.sock
usermod jenkins -aG docker
usermod ansible -aG docker
usermod ubuntu -aG docker 
chmod 666 /var/run/docker.sock

apt-get update && apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y terraform
usermod jenkins -aG docker
usermod ansible -aG docker

echo "Jenkins agent installation completed."
