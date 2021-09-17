#!/usr/bin/env bash

## The primary service for this jail will be installed in a Python Virtualenv
## When the python version changes, the virtualenv should be recreated

service_name='esphome'
service_port='6052'

## Which version of Python to use
service_python='python3.8'
## Location of the Virtualenv
service_venv="/usr/local/srv/${service_name}"
## Config directory for the service
service_config_dir="/var/db/${service_name}"

## Who will run the jail's primary service
## Here the user and group are both set to service_name
service_user="${service_name}"
service_group="${service_name}"
## Also, the UID is set to the service_port
service_uid="${service_port}"
## Home directory for the service_user
service_home="/usr/local/home/${service_user}"


# shellcheck disable=SC1091
. /etc/rc.subr && load_rc_config ${service_name}

service_python="${esphome_python:-$(which ${service_python})}"
service_venv="${esphome_venv:-${service_venv}}"
service_config_dir="${esphome_config_dir:-${service_config_dir}}"
service_user="${esphome_user:-${service_user}}"
service_group="${esphome_group:-${service_group}}"

run_once() {
  ## Add service_user, install the service_home and service_config_dir directories
  pw adduser -u "${service_uid}" -n "${service_user}" -d "${service_home}" -w no -s /usr/local/bin/bash
  install -d -m 775 -o "${service_user}" -g "${service_group}" -- "${service_home}"
  install -d -m 775 -o "${service_user}" -g "${service_group}" -- "${service_config_dir}"
  ## Launch the console menu upon login
  { echo -e "\n# Start console menu upon login." ; \
    echo "if ( -x /root/bin/menu ) menu" ; } >> /root/.login
}

set_rcvars() {
  echo -e "\nSetting rcvars for service...\n"
  sysrc ${service_name}_umask="002"
  sysrc ${service_name}_user="${service_user}"
  sysrc ${service_name}_group="${service_group}"
  sysrc ${service_name}_config_dir="${service_config_dir}"
  sysrc ${service_name}_python="${service_python}"
  sysrc ${service_name}_venv="${service_venv}"
}

install_toolchains() {
  ## This function is also called during a Plugin UPDATE
  local url pkg1 pkg2
  url=https://github.com/tprelog/iocage-esphome/raw/toolchains/toolchains
  pkg1=toolchain-xtensa-FreeBSD.12.amd64-2.40802.191122.pkg
  pkg2=toolchain-xtensa32-FreeBSD.12.amd64-2.50200.0.pkg
  echo -e "\nAttempting to add ESP8266 support for FreeBSD"
  fetch --quiet ${url}/${pkg1} -o /tmp/${pkg1} \
    && pkg install -y /tmp/${pkg1}
  echo -e "\nAttempting to add ESP32 support for FreeBSD"
  fetch --quiet ${url}/${pkg2} -o /tmp/${pkg2} \
    && pkg install -y /tmp/${pkg2}
  # shellcheck disable=SC2016
  su - "${service_user}" -c '
    mkdir -p ~/.platformio/packages
    cd ~/.platformio/packages || exit
    rm -rf -- toolchain-xtensa toolchain-xtensa32 xtensa-lx106-elf
    ln -s /usr/local/esp-quick-toolchain-gcc48/xtensa-lx106-elf .
    ln -s /usr/local/xtensa-esp32-elf-idf3 toolchain-xtensa32
  '
}

install_service() {
  echo -e "\nCreating virtualenv...\n"
  local required R='https://raw.githubusercontent.com/esphome/esphome/release/requirements.txt'
  local optional O='https://raw.githubusercontent.com/esphome/esphome/release/requirements_optional.txt'
  if [ -d "${service_venv}" ] && [ -n "$(ls -A "${service_venv}")" ]; then
    echo -e "${red} directory is not empty:${end} ${service_venv}" ; exit 1
  else
    required=$(mktemp -t "${service_name}.required")
    fetch --quiet ${R} -o "${required}" \
      && chown "${service_user}" "${required}"
    optional=$(mktemp -t "${service_name}.optional")
    fetch --quiet ${O} -o "${optional}" \
      && chown "${service_user}" "${optional}"
    install -d -g "${service_group}" -m 775 -o "${service_user}" -- "${service_venv}"
    # shellcheck disable=SC2016
    su - "${service_user}" -c '
      ${1} -m venv ${2}
      source ${2}/bin/activate || exit 1
        pip install --upgrade pip wheel
        pip install ${3} -r ${4} -r ${5} || exit 1
      deactivate
    ' _ "${service_python}" "${service_venv}" "${service_name}" "${required}" "${optional}"
    rm -f -- "${optional}" "${required}"
  fi
}

enablestart_service() {
  sysrc ${service_name}_enable=YES
  service ${service_name} start
}

upgrade_service() {
  local restart='N'
  service ${service_name} stop && restart='Y'
  # shellcheck disable=SC2016
  su - "${service_user}" -c '
    source ${1}/bin/activate || exit 1
      pip install --upgrade ${2}
    deactivate
  ' _ "${service_venv}" "${service_name}"
  if [ ${restart} == 'Y' ]; then
    service ${service_name} start
  fi
}

disablestop_service() {
  sysrc ${service_name}_enable=NO
  service ${service_name} onestop
}

remove_service() {
  local home; home="$(getent passwd "${service_user}" | cut -d: -f6)"
  echo -e "\n${orn}WARN:${end} You are about to remove ${service_name}"
  echo -e "${orn}WARN:${end} The following directory will be deleted -- ${service_venv}"
  echo -e "${orn}WARN:${end} The following directory will be deleted -- ${home}/.platformio"
  echo -e "${orn}WARN:${end} The following directory will be deleted -- ${home}/.cache\n"
  read -rp " Type 'YES' to continue: " response
  [[ "${response}" == [Yy][Ee][Ss] ]] || return 1 ; echo
  disablestop_service
  rm -rf -- "${service_venv}" "${home}/.platformio" "${home}/.cache"
}

unset_rcvars() {
  for var in $(eval sysrc -ae | grep ^"${service_name}"); do
    echo "removing rcvar: ${var}"
    sysrc -x "${var}" | cut -d= -f1
  done
}

show_url(){
  ## Get the jail's current ip address and show a link to the default admin portal
  service_ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
  echo -e "\nAdmin Portal:\nhttp://${service_ip}:${service_port}\n"
}

colors() {
  red=$'\e[1;31m'
  orn=$'\e[38;5;208m'
  end=$'\e[0m'
}; colors


if [ -z "${1}" ]; then
  ## Install the ESPHome iocage-plugin
  run_once \
    && set_rcvars \
    && install_service \
    && install_toolchains \
    && enablestart_service
elif [ "${1}" == 'install' ]; then
  install_service \
    && install_toolchains \
    && enablestart_service \
    && show_url
elif [ "${1}" == 'remove' ]; then
  remove_service
elif [ "${1}" == 'upgrade' ]; then
  upgrade_service
elif [ "${1}" == 'install-toolchains' ]; then
  install_toolchains
elif [ "${1}" == 'set-rcvars' ]; then
  set_rcvars
elif [ "${1}" == 'unset-rcvars' ]; then
  unset_rcvars
else
  echo "unknown: ${1}"
fi
