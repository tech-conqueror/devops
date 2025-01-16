#!/bin/bash

# Step 1: Update the package index
# This ensures the package manager has the latest information about available packages.
sudo apt-get update

# Step 2: Install prerequisites
# - `ca-certificates`: Required for HTTPS communication.
# - `curl`: Used to download files from URLs.
sudo apt-get install -y ca-certificates curl

# Step 3: Create a directory for Docker's GPG keyring
# The directory is created with appropriate permissions to securely store the GPG key.
sudo install -m 0755 -d /etc/apt/keyrings

# Step 4: Download Docker's GPG key
# The GPG key is used to verify the authenticity of packages from Docker's repository.
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc

# Step 5: Set permissions for the GPG key
# Ensures the key can be read by all users but not modified, enhancing security.
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Step 6: Add Docker's official repository to the APT sources list
# - The repository URL is specific to the Ubuntu version.
# - The GPG key is used to sign packages for secure installation.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 7: Update the package index again
# This time it includes packages from Docker's official repository.
sudo apt-get update

# Step 8: Install Docker and related packages
# - `docker-ce`: The Docker Community Edition runtime.
# - `docker-ce-cli`: Command-line interface for managing Docker.
# - `containerd.io`: A container runtime required by Docker.
# - `docker-buildx-plugin`: A plugin for advanced Docker build capabilities.
# - `docker-compose-plugin`: A plugin for managing multi-container applications.
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 9: Enable and start the Docker service
# Ensures Docker starts automatically on boot and runs immediately after installation.
sudo systemctl enable docker
sudo systemctl start docker

# Step 10: Add the current user to the Docker group
# This allows the user to run Docker commands without using `sudo`.
sudo usermod -aG docker $USER

# Step 11: Display the installed Docker version
# Verifies that Docker was installed successfully.
docker --version

# Step 12: Display a final message
# Advises the user to reboot the system to apply changes to the user group.
echo "Docker installation completed successfully. Please reboot your system to apply user group changes."
