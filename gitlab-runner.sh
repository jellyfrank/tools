#!/bin/bash

set -e

DEFAULT_URL="http://git.odoohub.com.cn"

echo "===== GitLab Runner Setup ====="

read -p "Enter GitLab URL [default: $DEFAULT_URL]: " GITLAB_URL
GITLAB_URL=${GITLAB_URL:-$DEFAULT_URL}

read -p "Enter GitLab Runner Token: " RUNNER_TOKEN

echo ""

# 1 检查 gitlab-runner 是否已安装
if command -v gitlab-runner >/dev/null 2>&1; then
    echo "GitLab Runner already installed"
    gitlab-runner --version
else
    echo "Installing GitLab Runner..."

    sudo apt-get update
    sudo apt-get install -y curl gnupg ca-certificates

    if [ ! -f /usr/share/keyrings/gitlab-runner.gpg ]; then
        curl -fsSL https://packages.gitlab.com/runner/gitlab-runner/gpgkey \
        | sudo gpg --dearmor -o /usr/share/keyrings/gitlab-runner.gpg
    fi

    if [ ! -f /etc/apt/sources.list.d/gitlab-runner.list ]; then
        echo "deb [signed-by=/usr/share/keyrings/gitlab-runner.gpg] https://packages.gitlab.com/runner/gitlab-runner/ubuntu/ focal main" \
        | sudo tee /etc/apt/sources.list.d/gitlab-runner.list
    fi

    sudo apt-get update
    sudo apt-get install -y gitlab-runner
fi


# 2 创建 runner 目录
if [ ! -d /var/lib/gitlab-runner ]; then
    echo "Creating runner directory..."
    sudo mkdir -p /var/lib/gitlab-runner
    sudo chown -R gitlab-runner:gitlab-runner /var/lib/gitlab-runner
fi


# 3 配置 sudo
if ! sudo grep -q "gitlab-runner ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "Adding gitlab-runner to sudoers..."
    echo "gitlab-runner ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
else
    echo "sudoers already configured"
fi


# 4 检查 runner 是否已经注册
RUNNER_COUNT=$(sudo gitlab-runner list 2>/dev/null | grep -c "executor")

if [ "$RUNNER_COUNT" -eq 0 ]; then
    echo "Registering Runner..."

    sudo gitlab-runner register \
    --non-interactive \
    --url "$GITLAB_URL" \
    --token "$RUNNER_TOKEN" \
    --executor "shell" \
    --description "$(hostname)-runner"

else
    echo "Runner already registered"
fi


# 5 启动 runner
echo "Ensuring service running..."

sudo systemctl enable gitlab-runner
sudo systemctl restart gitlab-runner


echo ""
echo "===== Runner List ====="
gitlab-runner list

echo ""
echo "===== Setup Complete ====="