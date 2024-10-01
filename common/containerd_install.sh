#!/bin/bash

# Step 1: Load required kernel modules
# These modules are prerequisites for Containerd and Kubernetes.
# - `overlay`: Provides a union filesystem layer for container images.
# - `br_netfilter`: Enables bridge network filtering for iptables to manage network traffic.
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Load the modules immediately to ensure they are active for the current session.
sudo modprobe overlay
sudo modprobe br_netfilter

# Step 2: Configure sysctl parameters for Kubernetes networking
# These settings enable packet forwarding and proper network traffic handling:
# - `net.bridge.bridge-nf-call-iptables`: Ensures bridged network traffic is processed by iptables.
# - `net.bridge.bridge-nf-call-ip6tables`: Ensures IPv6 bridged traffic is also processed by iptables.
# - `net.ipv4.ip_forward`: Enables forwarding of IPv4 traffic, necessary for pod communication.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply the sysctl parameters immediately without requiring a system reboot.
sudo sysctl --system

# Step 3: Install Containerd
# Containerd is a lightweight, high-level container runtime that Kubernetes uses to manage containers.
sudo apt-get install -y containerd

# Step 4: Create a default Containerd configuration file
# This configuration file defines how Containerd operates, including runtime settings and cgroup driver configurations.
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Step 5: Update Containerd to use the `systemd` cgroup driver
# Kubernetes recommends using the `systemd` cgroup driver for compatibility with kubelet.
# The following command modifies the configuration to set `SystemdCgroup` to `true`.
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

# Verify that the configuration was updated correctly
grep 'SystemdCgroup = true' /etc/containerd/config.toml

# Step 6: Restart Containerd to apply the new configuration
sudo systemctl restart containerd

# Step 7: Prevent accidental updates to Containerd
# This command marks Containerd as held, ensuring that it won't be updated unintentionally during a system upgrade.
sudo apt-mark hold containerd
