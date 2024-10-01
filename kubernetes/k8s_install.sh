#!/bin/bash

# Step 1: Install prerequisites
# - `apt-transport-https`: Enables the use of HTTPS for APT repositories.
# - `ca-certificates`: Ensures secure communication over HTTPS.
# - `curl`: A command-line tool for downloading data from URLs.
# - `gpg`: Used for managing GPG keys.
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Step 2: Download and store Kubernetes' GPG key
# - Fetches the GPG key used to verify the authenticity of Kubernetes packages.
# - Stores the key in `/etc/apt/keyrings` to be referenced by APT.
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Step 3: Add the Kubernetes APT repository
# - Adds the stable Kubernetes repository for version 1.29 packages.
# - Specifies the signed GPG key to verify packages from the repository.
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Step 4: Update the APT package list
# - Refreshes the list of available packages, including those from the newly added Kubernetes repository.
sudo apt-get update

# Inspect available versions of the `kubelet` package
# - Displays the first 20 lines of available `kubelet` versions to help decide which version to install.
apt-cache policy kubelet | head -n 20

# Step 5: Install specific versions of Kubernetes components
# - Installs `kubelet`, `kubeadm`, and `kubectl` of the specified version.
# - These components are essential for running and managing a Kubernetes cluster:
#   - `kubelet`: The node agent that runs and manages containers.
#   - `kubeadm`: A tool to bootstrap Kubernetes clusters.
#   - `kubectl`: Command-line tool for interacting with the Kubernetes API.
# - The specific version is chosen to support a later cluster upgrade.
VERSION=1.29.1-1.1
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION

# Step 6: Hold the installed packages to prevent automatic upgrades
# - Prevents `kubelet`, `kubeadm`, `kubectl`, and `containerd` from being upgraded inadvertently.
# - This ensures cluster stability until explicitly upgraded in a controlled manner.
sudo apt-mark hold kubelet kubeadm kubectl containerd
