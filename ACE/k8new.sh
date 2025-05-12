#!/bin/bash
set -e

echo "[Step 1] Updating the system..."
sudo yum update -y || sudo apt update -y

echo "[Step 2] Installing basic utilities..."
sudo yum install -y curl wget git || sudo apt install -y curl wget git

echo "[Step 3] Disabling Swap (Kubernetes requirement)..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "[Step 4] Installing containerd..."
sudo yum install -y containerd || sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

echo "[Step 5] Updating containerd config (SystemdCgroup=true)..."
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "[Step 6] Adding Kubernetes repository..."
# Amazon Linux
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
# Ubuntu alternative
sudo apt-get install -y apt-transport-https ca-certificates curl || true
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg || true
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list || true
sudo apt update || true

echo "[Step 7] Installing kubeadm, kubelet, and kubectl..."
sudo yum install -y kubelet kubeadm kubectl || sudo apt install -y kubelet kubeadm kubectl

echo "[Step 8] Enabling kubelet service..."
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo "[Step 9] Initializing Kubernetes cluster..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "[Step 10] Setting up kubeconfig for current user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[Step 11] Allow scheduling pods on master (single-node cluster)..."
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
kubectl taint nodes --all node-role.kubernetes.io/master- || true

echo "[Step 12] Installing Flannel CNI network plugin..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "[Step 13] Kubernetes cluster setup is complete! 🎉"
kubectl get nodes
