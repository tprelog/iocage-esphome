<!-- BADGE LINKS -->
[plugins-link]:https://www.truenas.com/plugins/
[plugins-shield]:https://img.shields.io/badge/TrueNAS%20CORE-Community%20Plugin-blue?logo=TrueNAS&style=for-the-badge
<!-- CIRRUS CI RESULTS -->
[results-12.2]:https://cirrus-ci.com/github/tprelog/truenas-plugin-index/12.2-RELEASE?task=esphome-12-2
[core-12.2]:https://img.shields.io/cirrus/github/tprelog/truenas-plugin-index/12.2-RELEASE?task=esphome-12-2&label=12.2-RELEASE&logo=FreeBSD&logoColor=red&style=for-the-badge

# iocage-esphome

Artifact file(s) for [ESPHome][1] (python virtualenv)

<!-- BADGE SHIELDS -->
[![x][plugins-shield]][plugins-link] [![x][core-12.2]][results-12.2]

:warning: This plugin is not actively maintained

- ESPHome will be installed in a Python Virtualenv

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
ESPHome | esphome | /usr/local/srv/esphome | 6052 | esphome | /var/db/esphome

#### USB devices are not supported in ESPHome on TrueNAS

*There is currently no USB detection for device flashing on TrueNAS*. You can create, compile and download the initial firmware using ESPHome on TrueNAS. *You will need to use esphomeflasher on a separate computer for the initial flash*. After the initial flash and your device is connected to your network, you will be able to manage and flash future firmwares using the ESPHome OTA process.

[1]: https://esphome.io/
