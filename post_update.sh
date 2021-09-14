#!/usr/bin/env bash

# shellcheck disable=SC1091
. /etc/rc.subr && load_rc_config
: "${plugin_enable_pkglist:="NO"}"

install_pkglist() {
  ## If enabled, re-install packages from a pkglist, after a Plugin UPDATE
  ## Use `sysrc plugin_pkglist="/path/to/pkglist"` to set a pkglist
  ## Use `sysrc plugin_enable_pkglist=YES` to enable
  local pkgs ; pkgs=$(cat "${plugin_pkglist:-/dev/null}")
  echo -e "\nChecking for additional packages to install..."
  echo "${pkgs}" | xargs pkg install -y
}

update_console_menu() {
  ## The old console menu 'hass-helper' was replaced with 'menu'
  if [ -f /root/bin/hass-helper ] && [ -x /root/bin/menu ]; then
    sed -i '' "s/hass-helper/menu/g" /root/.login \
      && rm /root/bin/hass-helper
  fi
}

update_post_install() {
  ## post_install.sh is not automatically updated after the initial plugin installation
  ## Since its functions are also used by the console menu, it should be kept up to date
  local url='https://raw.githubusercontent.com/tprelog/iocage-esphome/master/post_install.sh'
  fetch --quiet -o /root/post_install.sh ${url} \
    && chmod +x /root/post_install.sh
}

update_toolchains() {
  /root/post_install.sh 'install-toolchains'
}

checkyesno plugin_enable_pkglist && install_pkglist

update_console_menu
update_post_install
update_toolchains
