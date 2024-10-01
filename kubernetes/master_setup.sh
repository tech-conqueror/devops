#!/bin/bash

# Step 1: Install Containerd
# Downloads and executes a script to set up the Containerd required for Kubernetes.
curl -sL https://raw.githubusercontent.com/tech-conqueror/cicd/master/common/containerd_install.sh | bash

# Step 2: Install Kubernetes components (kubelet, kubeadm, kubectl)
# Downloads and executes a script to set up Kubernetes components necessary to manage the cluster.
curl -sL https://raw.githubusercontent.com/tech-conqueror/cicd/master/kubernetes/k8s_install.sh | bash

# Step 3: Install Helm package manager
# Downloads and executes a script to set up Helm, a package manager for Kubernetes.
curl -sL https://raw.githubusercontent.com/tech-conqueror/cicd/master/common/helm_install.sh | bash

# Step 4: Initialize the Kubernetes cluster
# Uses kubeadm to bootstrap a Kubernetes cluster with the specified version.
sudo kubeadm init --kubernetes-version v1.29.1

# Step 5: Set up kubeconfig for the current user
# Configures kubectl (the Kubernetes CLI) to interact with the cluster by:
# - Creating the `.kube` directory in the user's home directory.
# - Copying the Kubernetes admin configuration file to the user's `.kube` directory.
# - Changing ownership of the configuration file to the current user.
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step 6: Install Calico as the cluster's network plugin
# Applies the Calico manifest to set up Calico, a container networking solution, for the Kubernetes cluster.
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml

# Step 7: Install NGINX Ingress Controller
# Applies the NGINX Ingress Controller manifest to enable ingress capabilities for the Kubernetes cluster.
# This specific controller is designed for bare-metal environments and facilitates routing of external HTTP and HTTPS 
# traffic to services within the cluster. It provides features like SSL termination, load balancing, and URL-based routing.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/baremetal/deploy.yaml
