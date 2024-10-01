#!/bin/bash

# Step 1: Install Containerd
# Downloads and executes a script to set up Containerd, the container runtime used by Kubernetes.
curl -sL https://raw.githubusercontent.com/tech-conqueror/cicd/master/common/containerd_install.sh | bash

# Step 2: Install Kubernetes components (kubelet, kubeadm, kubectl)
# Downloads and executes a script to install Kubernetes components required to manage a cluster.
curl -sL https://raw.githubusercontent.com/tech-conqueror/cicd/master/kubernetes/k8s_install.sh | bash
