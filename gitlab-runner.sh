#!/bin/bash

set -e

DEFAULT_URL="http://git.odoohub.com.cn"

echo "===== Install GitLab Runner ====="

read -p "Enter GitLab URL [default: $DEFAULT_URL]: " GITLAB_URL
GITLAB_URL=${GITLAB_URL:-$DEFAULT_URL}

read -p "Enter GitLab Runner Token: " RUNNER_TOKEN

read -p "Enter Runner Tag [default: Carmarge]: " RUNNER_TAG
RUNNER_TAG=${RUNNER_TAG:-Carmarge}

echo ""
echo "GitLab URL: $GITLAB_URL"
echo "Runner Tag: $RUNNER_TAG"
echo ""

echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl gnupg ca-certificates

echo "Adding GitLab Runner repository..."
curl -fsSL https://packages.gitlab.com/runner/gitlab-runner/gpgkey \
| sudo gpg --dearmor -o /usr/share/keyrings/gitlab-runner.gpg

echo "deb [signed-by=/usr/share/keyrings/gitlab-runner.gpg] https://packages.gitlab.com/runner/gitlab-runner/ubuntu/ focal main" \
| sudo tee /etc/apt/sources.list.d/gitlab-runner.list

echo "Installing GitLab Runner..."
sudo apt-get update
sudo apt-get install -y gitlab-runner

echo "GitLab Runner version:"
gitlab-runner --version

echo "Creating runner directory..."
sudo mkdir -p /var/lib/gitlab-runner
sudo chown -R gitlab-runner:gitlab-runner /var/lib/gitlab-runner

echo "Adding gitlab-runner to sudoers..."

if ! sudo grep -q "gitlab-runner ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "gitlab-runner ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
fi

echo "Registering Runner..."

sudo gitlab-runner register \
--non-interactive \
--url "$GITLAB_URL" \
--token "$RUNNER_TOKEN" \
--executor "shell" \
--description "ProductionRunner" \
--tag-list "$RUNNER_TAG" \
--run-untagged="false" \
--locked="false"

echo "Starting GitLab Runner..."

sudo systemctl enable gitlab-runner
sudo systemctl restart gitlab-runner

echo ""
echo "Installed runners:"
gitlab-runner list

echo ""
echo "===== GitLab Runner Installation Complete ====="