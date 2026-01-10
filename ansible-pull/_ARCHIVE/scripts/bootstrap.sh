#!/usr/bin/env bash
set -e

# INFO: Configuration
REPO_URL="https://github.com/rtdevx/cicd-ansible-pull"
RAW_URL="https://raw.githubusercontent.com/rtdevx/cicd-ansible-pull/main"
PLAYBOOK="playbooks/common.yml"

# INFO: Ensure ansible user exists
echo "Ensuring ansible user exists..."

if ! id ansible >/dev/null 2>&1; then
    echo "Creating ansible user..."
    sudo useradd \
        --system \
        --create-home \
        --shell /usr/sbin/nologin \
        ansible
fi

# INFO: Configure passwordless sudo for ansible user
echo "Configuring sudo privileges..."
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible >/dev/null
sudo chmod 440 /etc/sudoers.d/ansible

# INFO: Prepare SSH directory for ansible user
echo "Preparing SSH directory for ansible user..."

sudo -u ansible mkdir -p /home/ansible/.ssh
sudo chmod 700 /home/ansible/.ssh
sudo chown ansible:ansible /home/ansible/.ssh

# INFO: Install dependencies
echo "Installing dependencies..."
sudo apt update -y
sudo apt install -y ansible git curl python3 python3-venv python3-pip # NOTE: Required packages. Without those, ansible‑pull will fail silently.

# INFO: Prepare logfile
echo "Preparing logfile..."
sudo touch /var/log/ansible.log
sudo chown ansible:ansible /var/log/ansible.log
sudo chmod 755 /var/log/ansible.log

# INFO: Prepare ansible working directory
echo "Preparing ansible working directory..."
sudo -u ansible mkdir -p /home/ansible/.ansible/pull
sudo chown -R ansible:ansible /home/ansible/.ansible

# INFO: Create ansible-pull wrapper
echo "Creating ansible-pull wrapper..."
sudo tee /usr/local/bin/ansible-pull-wrapper >/dev/null <<EOF
#!/usr/bin/env bash
/usr/bin/ansible-pull -U "$REPO_URL" "$PLAYBOOK" --clean
EOF

sudo chmod +x /usr/local/bin/ansible-pull-wrapper

# INFO: Install systemd service and timer
echo "Installing systemd service and timer..."

sudo curl -s -o /etc/systemd/system/ansible-pull.service \
  "$RAW_URL/systemd/ansible-pull.service"

sudo curl -s -o /etc/systemd/system/ansible-pull.timer \
  "$RAW_URL/systemd/ansible-pull.timer"

# INFO: Reload systemd and enable timer
echo "Reloading systemd and enabling timer..."
sudo systemctl daemon-reload
sudo systemctl enable --now ansible-pull.timer

# INFO: Bootstrap complete
echo "Bootstrap complete."