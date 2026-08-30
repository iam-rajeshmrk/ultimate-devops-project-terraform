#!/usr/bin/env bash
set -euo pipefail

echo "=== 1. Updating base system and prerequisites ==="
sudo apt-get update -y

echo "install unzip command"
sudo apt-get install -y unzip

echo "=== 2. Installing AWS CLI v2 ==="
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q -o awscliv2.zip
sudo ./aws/install


echo "=== 3. Installing Docker CE ==="
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

# Grant current user docker socket access without sudo
sudo usermod -aG docker "$USER"

echo "=== 4. Installing Kubectl ==="
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo apt-get update
sudo apt-get install -y kubectl


echo "=== 5. Installing Terraform ==="
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y terraform

echo "=== 6. Installing Helm 3 ==="
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


echo "=========================================="
echo " Installation Complete!"
echo " IMPORTANT: Run 'newgrp docker' or re-login"
echo " to apply Docker group permissions."
echo "=========================================="

version_info() {
    echo "=== Installed Versions ==="
    echo "AWS CLI: $(aws --version)"
    echo "Docker: $(docker --version)"
    echo "Kubectl: $(kubectl version --client --short)"
    echo "Kubectl Cluster Info:" $(kubectl cluster-info)
    echo "Terraform: $(terraform version | head -n 1)"
    echo "Helm: $(helm version --short)"
}

version_info() #calling the function to display installed versions
