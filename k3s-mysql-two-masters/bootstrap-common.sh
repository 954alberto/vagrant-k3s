#!/usr/bin/env bash
apt-get update
apt-get remove docker docker.io containerd runc
apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y mysql-server mysql-client mysql-common keepalived && mysqladmin version
sysctl -w net.ipv4.ip_nonlocal_bind=1
sysctl -w net.ipv4.ip_forward=1
systemctl stop ufw.service
systemctl disable ufw.service
# Installing K3S
mkdir -p /etc/rancher/k3s
cp /vagrant/config/${HOSTNAME}/k3s/config.yaml /etc/rancher/k3s/config.yaml
curl -sfL https://get.k3s.io -o /usr/local/bin/k3s
chmod 755 /usr/local/bin/k3s
/usr/local/bin/k3s server --config=/etc/rancher/k3s/config.yaml 
systemctl stop k3s
echo 'export INSTALL_K3S_VERSION=v1.21.1' >>~/.bashrc
export INSTALL_K3S_VERSION=v1.21.1
curl -sfL  https://github.com/k3s-io/k3s/releases/download/v1.21.1%2Bk3s1/k3s -o /usr/local/bin/k3s
chmod 755 /usr/local/bin/k3s
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
curl -sfL https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx
curl -sfL https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens
chmod 755 /usr/local/bin/kubectx
chmod 755 /usr/local/bin/kubens


