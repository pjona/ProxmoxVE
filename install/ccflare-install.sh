#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: pjona
# License: MIT | https://github.com/pjona/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/snipeship/ccflare

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  git \
  unzip
msg_ok "Installed Dependencies"

msg_info "Installing Bun"
export BUN_INSTALL=/opt/bun
curl -fsSL https://bun.sh/install | $STD bash
ln -sf /opt/bun/bin/bun /usr/local/bin/bun
ln -sf /opt/bun/bin/bunx /usr/local/bin/bunx
msg_ok "Installed Bun"

msg_info "Cloning ccflare"
$STD git clone https://github.com/snipeship/ccflare /opt/ccflare-src
msg_ok "Cloned ccflare"

msg_info "Building ccflare (Patience)"
mkdir -p /opt/ccflare/data
cd /opt/ccflare-src || exit
$STD bun install
$STD bun run build
msg_ok "Built ccflare"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/ccflare.service
[Unit]
Description=ccflare Claude API Load Balancer
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/ccflare-src
ExecStart=/opt/ccflare-src/apps/tui/dist/ccflare --serve
Restart=on-failure
RestartSec=5
Environment="PORT=8080"
Environment="LOG_LEVEL=INFO"
Environment="LOG_FORMAT=json"
Environment="ccflare_DB_PATH=/opt/ccflare/data/ccflare.db"

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now ccflare
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
