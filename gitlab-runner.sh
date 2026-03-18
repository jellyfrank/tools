#!/bin/bash

set -e

DEFAULT_URL="https://git.odoohub.com.cn"
CONFIG_FILE="/etc/gitlab-runner/config.toml"

echo "===== GitLab Runner Setup ====="

# ========================

# 0. 输入参数

# ========================

read -p "Enter GitLab URL [default: $DEFAULT_URL]: " GITLAB_URL
GITLAB_URL=${GITLAB_URL:-$DEFAULT_URL}

read -p "Enter GitLab Registration Token: " RUNNER_TOKEN

read -p "Force re-register runner? (y/N): " FORCE

echo ""

# ========================

# 1. 安装 GitLab Runner

# ========================

if command -v gitlab-runner >/dev/null 2>&1; then
echo "✔ GitLab Runner already installed"
gitlab-runner --version
else
echo "➡ Installing GitLab Runner..."

```
sudo apt-get update
sudo apt-get install -y curl gnupg ca-certificates

# 导入 GPG key（国内可用）
if [ ! -f /usr/share/keyrings/gitlab-runner.gpg ]; then
    curl -fsSL https://packages.gitlab.com/runner/gitlab-runner/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/gitlab-runner.gpg
fi

# 添加源
if [ ! -f /etc/apt/sources.list.d/gitlab-runner.list ]; then
    echo "deb [signed-by=/usr/share/keyrings/gitlab-runner.gpg] https://packages.gitlab.com/runner/gitlab-runner/ubuntu/ focal main" \
    | sudo tee /etc/apt/sources.list.d/gitlab-runner.list
fi

sudo apt-get update
sudo apt-get install -y gitlab-runner
```

fi

# ========================

# 2. 创建目录

# ========================

if [ ! -d /var/lib/gitlab-runner ]; then
echo "➡ Creating runner directory..."
sudo mkdir -p /var/lib/gitlab-runner
sudo chown -R gitlab-runner:gitlab-runner /var/lib/gitlab-runner
fi

# ========================

# 3. sudo 权限（安全方式）

# ========================

if [ ! -f /etc/sudoers.d/gitlab-runner ]; then
echo "➡ Configuring sudoers..."
echo "gitlab-runner ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/gitlab-runner
sudo chmod 440 /etc/sudoers.d/gitlab-runner
else
echo "✔ sudoers already configured"
fi

# ========================

# 4. 强制重注册（可选）

# ========================

if [[ "$FORCE" == "y" || "$FORCE" == "Y" ]]; then
echo "➡ Forcing re-registration..."
sudo gitlab-runner unregister --all-runners || true
sudo rm -f $CONFIG_FILE
fi

# ========================

# 5. 注册 Runner（关键修复点）

# ========================

if [ ! -f "$CONFIG_FILE" ] || ! sudo grep -q "url" "$CONFIG_FILE"; then
echo "➡ Registering Runner..."

```
sudo gitlab-runner register \
    --non-interactive \
    --url "$GITLAB_URL" \
    --registration-token "$RUNNER_TOKEN" \
    --executor "shell" \
    --description "$(hostname)-runner" \
    --tag-list "shell" \
    --run-untagged="true" \
    --locked="false"
```

else
echo "✔ Runner already registered"
fi

# ========================

# 6. 启动服务

# ========================

echo "➡ Ensuring service running..."

sudo systemctl enable gitlab-runner
sudo systemctl restart gitlab-runner

# ========================

# 7. 输出结果

# ========================

echo ""
echo "===== Runner List ====="
sudo gitlab-runner list || true

echo ""
echo "===== Config ====="
sudo cat $CONFIG_FILE || true

echo ""
echo "===== Setup Complete ====="
