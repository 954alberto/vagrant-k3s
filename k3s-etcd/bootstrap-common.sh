#!/usr/bin/env bash
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io keepalived
sudo sysctl -w net.ipv4.ip_nonlocal_bind=1
sudo sysctl -w net.ipv4.ip_forward=1
sudo systemctl stop ufw.service
sudo systemctl disable ufw.service
whoami
export INSTALL_K3S_VERSION=v1.21.1
sudo INSTALL_K3S_VERSION=v1.21.1 ; curl -sfL https://get.k3s.io -o /usr/local/bin/k3s
sudo chmod 755 /usr/local/bin/k3s
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo echo 'source <(kubectl completion bash)' >>~/.bashrc
sudo echo 'alias k=kubectl' >>~/.bashrc
sudo echo 'complete -F __start_kubectl k' >>~/.bashrc
sudo curl -sfL https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx
sudo curl -sfL https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens
sudo chmod 755 /usr/local/bin/kubectx
chmod 755 /usr/local/bin/kubens
sudo mkdir /etc/keepalived
sudo cp /vagrant/config/${HOSTNAME}/keepalived.conf /etc/keepalived/keepalived.conf
sudo chmod 644 /etc/keepalived/keepalived.conf
sudo systemctl enable keepalived
sudo systemctl restart keepalived
sudo mkdir /etc/rancher/k3s
sudo cp /vagrant/config/${HOSTNAME}/config.yaml /etc/rancher/k3s/config.yaml
