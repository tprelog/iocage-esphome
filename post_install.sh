#!/usr/bin/env bash

  # pkg install autoconf bash ca_root_nss curl gcc git-lite gmake pkgconf python37 py37-pillow
  # git clone https://github.com/tprelog/iocage-esphome.git /root/.iocage-esphome
  # bash /root/.iocage-esphome/post_install.sh standard

## Ensure that 'curl' and 'py38-pillow' have been installed
# (These are currently not listed in the plugin manifest)
pkg install -y curl py38-pillow

## Changing these variables is not fully supported in this script.
#   These values may still be "hard-coded" in other locations.

plugin_overlay="/root/.iocage-esphome/overlay"   # Used for `post_install.sh standard`

v2srv=esphome       # This script only supports installing "ESPHome"
v2srv_port=6052     # The default port used by ESPHome

python=python3
ve_dir=/usr/local/srv   # example alternative: /srv
ve_conf=/var/db         # example alternative: /home

v2srv_user=esphome  # Matches the name of the service
v2srv_uid=6052      # Matches default port of the service

_srv_ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

_srv_dir="${ve_dir}/${v2srv}"
_srv_conf="${ve_conf}/${v2srv}"

script="${0}"
ctrl="$(basename "${0}" .sh)"

first_run () {
  sed "s/^umask.*/umask 2/g" .cshrc > .cshrcTemp && mv .cshrcTemp .cshrc
  echo -e "\n# Start hass-helper after login." >> /root/.login
  echo "if ( -x /root/bin/hass-helper ) hass-helper" >> /root/.login
  
  add_user
  install_service
}

add_user () {
  local _home
  _home="${_srv_conf}"
  install -d -g ${v2srv_uid} -o ${v2srv_uid} -m 775 -- ${_home}
  pw addgroup -g ${v2srv_uid} -n ${v2srv_user}
  pw adduser -u ${v2srv_uid} -n ${v2srv_user} -d ${_home} -w no -s /usr/local/bin/bash -G dialer
}

install_service() {
  
  local _python
  _python=$(which ${python})
  
  echo -e "\nPrepairing to install service"
  
  if [ ! -d ${_srv_dir} ]; then
    install -d -g ${v2srv_user} -o ${v2srv_user} -m 775 -- ${_srv_dir} || exit
  elif [ ! -z "$(ls -A ${_srv_dir})" ]; then  
    echo -e "${red}\nvirtualenv directory found and it's not empty!\n${orn} Is ${v2srv} already installed?"
    echo -e " You can remove ${_srv_dir} and try again${end}\n"; exit
  fi
  
  if [ ! -d ${_srv_conf} ]; then
    install -d -g ${v2srv_user} -o ${v2srv_user} -m 700 \
    -- {${_srv_conf},${_srv_conf}/.cache,${_srv_conf}/.platformio} || exit
  fi
  
  ## Workaround related "/.cache" and "/.platformio" permission errors
  ln -s {${_srv_conf}/.cache,${_srv_conf}/.platformio} /
  # remove: rm -rf {/.platformio,/.cache}
  
    su ${v2srv_user} -c '
    echo -e "Installing ${4}...\n"
    cd ${3}
    
    ${1} -m venv ${2}
    source ${2}/bin/activate || exit 1
    pip3 install --upgrade pip wheel
    pip3 install esphome pillow
    deactivate
    
    ## Platformio is missing, or no longer provides the required toolchains for *BSD
    ## This attempts to use an existing copy of the previous toolchain until a new version can be compiled
    url2=https://github.com/tprelog/iocage-esphome/raw/toolchain-hack/toolchains
    pkg2=toolchain-xtensa-freebsd_amd64-2.40802.191122-HACK.tar.gz
    
    echo -e "\nAttempting to add ESP8266 support on FreeBSD...\n"
    curl -o /tmp/toolchain-xtensa.tar.gz -OLs ${url2}/${pkg2} \
    && mkdir -p "${3}/.platformio/packages" \
    && tar -x -C "${3}/.platformio/packages" -f /tmp/toolchain-xtensa.tar.gz \
    || echo -e "\nFailed to add ESP8266 support -- missing toolchain-xtensa"
    
    ## Download and install extra files needed for esp32 support on *BSD
    ## Thank You to @CyanoFresh for sharing this (link below)
    ## https://github.com/tprelog/iocage-homeassistant/issues/5#issuecomment-573179387
    
    url=https://github.com/trombik/toolchain-xtensa32/releases/download/0.2.0
    pkg=toolchain-xtensa32-FreeBSD.11.amd64-2.50200.80.tar.gz
    
    echo -e "\nAttempting to add ESP32 support on FreeBSD...\n"
    curl -o /tmp/${pkg} -OLs ${url}/${pkg} \
    && mkdir -p "${3}/.platformio/packages/toolchain-xtensa32" \
    && tar -x -C "${3}/.platformio/packages/toolchain-xtensa32" -f /tmp/${pkg} \
    || echo -e "\nFailed to add ESP32 support -- missing toolchain-xtensa32"
    
  ' _ ${_python} ${_srv_dir} ${_srv_conf} ${v2srv} || exit
  
  ln -s "${_srv_dir}/bin/${v2srv}" "/usr/local/bin/${v2srv}"
  enableStart_v2srv
}

enableStart_v2srv () {
#   echo -e "\nAttempting to start ${v2srv}...\n"
  chmod +x /usr/local/etc/rc.d/${v2srv}
  sysrc -f /etc/rc.conf ${v2srv}_enable=yes
  service ${v2srv} start; sleep 1
}

cp_overlay() {
  ## This function is used for `post_install standard`
  mkdir -p /root/bin
  
  ln -s ${0} /root/bin/update
  ln -s ${0} /root/bin/refresh
  ln -s ${0} /root/post_install.sh
  
  ln -s ${plugin_overlay}/root/bin/hass-helper /root/bin/hass-helper
  
  mkdir -p /usr/local/etc/rc.d
  cp -R ${plugin_overlay}/usr/local/etc/ /usr/local/etc/
  #cp ${plugin_overlay}/etc/motd /etc/motd
  #chmod -R +x /usr/local/etc/rc.d/
}

colors () {         # Define Some Colors for Messages
  red=$'\e[1;31m'
  grn=$'\e[1;32m'
  yel=$'\e[1;33m'
  bl1=$'\e[1;34m'
  mag=$'\e[1;35m'
  cyn=$'\e[1;36m'
  blu=$'\e[38;5;39m'
  orn=$'\e[38;5;208m'
  end=$'\e[0m'
}
colors

if [ "${ctrl}" = "post_install" ]; then
  
  if [ -z "${1}" ]; then
    # Install ESPHome in a FreeNAS plugin-jail
    first_run
    
  elif [ "${1}" = "standard" ]; then
    # Install ESPHome in a FreeNAS standard-jail
    cp_overlay || exit 1
    first_run || exit 1
    service ${v2srv} status \
    && echo -e "\n ${grn}http://${_srv_ip}:${v2srv_port}${end}\n"
    
  elif [ "${1}" = "esphome" ]; then
    # Used by this FreeNAS jail to (Re)install ESPHome
    install_service && echo; service ${v2srv} status \
    && echo -e "\n ${grn}http://${_srv_ip}:${v2srv_port}${end}\n"
    
  else
    echo "${red}post_install.sh - Nothing to do.${end}"
    echo " script: ${script}"
    echo " crtl name: ${ctrl}"
    echo " arguments: ${@}"
  fi
  
  exit
fi



#--------------------------------------------------------------------------------- ,
# --- CODE BELOW THIS LINE IS USED FOR A "SATNDARD JAIL INSTALL" ----------------- ,

upgrade_menu () {
  while true; do
    echo
    PS3="${cyn} Enter Number to Upgrade${end}: "
    select OPT in "ESPHome" "FreeBSD" "Exit"
    do
      case ${OPT} in
        "ESPHome")
          service esphome upgrade; break
          ;;
        "FreeBSD")
          pkg update && pkg upgrade; break
          ;;
        "Exit")
          exit
          ;;
      esac
    done
  done
}

case $@ in
  "update")
    upgrade_menu
    ;;
  "refresh")
    git -C /root/.iocage-esphome/ pull
    exit
    ;;
esac

if [ "${ctrl}" = "update" ]; then
    script="$(realpath "$BASH_SOURCE")"
    upgrade_menu
else
    echo "${red}! Finished with Nothing To Do !${end}"
    echo "script: ${script} "
    echo "crtl name: ${ctrl} "
    echo "arguments: ${@} "
fi
