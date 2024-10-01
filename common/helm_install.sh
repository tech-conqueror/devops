#!/bin/bash

# Step 1: Download Helm's GPG signing key, convert it to binary format, and store it in a secure location.
# The key will be used to verify the authenticity of the Helm package repository.
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

# Step 2: Add Helm's official repository to the system's APT sources list.
# This allows the system to fetch Helm packages from the specified URL.
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Step 3: Update the APT package list to include the packages from the newly added Helm repository.
sudo apt-get update

# Step 4: Install Helm using the APT package manager.
# This will download and install the latest version of Helm available in the repository.
sudo apt-get install helm
