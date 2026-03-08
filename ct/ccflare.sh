#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/pjona/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: pjona
# License: MIT | https://github.com/pjona/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/snipeship/ccflare

APP="ccflare"
var_tags="${var_tags:-ai;proxy}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/ccflare-src ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  if git -C /opt/ccflare-src pull | grep -q 'Already up to date'; then
    msg_ok "There is currently no update available."
    exit
  fi
  msg_info "Stopping Service"
  systemctl stop ccflare
  msg_ok "Stopped Service"

  msg_info "Building ccflare"
  cd /opt/ccflare-src || exit
  $STD bun install
  $STD bun run build
  cp /opt/ccflare-src/apps/tui/dist/ccflare /opt/ccflare/ccflare
  msg_ok "Built ccflare"

  msg_info "Starting Service"
  systemctl start ccflare
  msg_ok "Started Service"
  msg_ok "Updated successfully!"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
echo -e "${INFO}${YW} Dashboard available at:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080/dashboard${CL}"
