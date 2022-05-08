#!/usr/bin/env bash
echo "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/bin/kubectl

echo 'Removing "ubuntu" user from the "sudo" group'
gpasswd -d ubuntu sudo

echo "Removing file sudoers file that enables ubuntu to always have root access"
rm /etc/sudoers.d/90-cloud-init-users
