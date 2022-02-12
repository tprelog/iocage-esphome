<!-- markdownlint-disable MD012 MD041 -->

<!-- BADGE LINKS -->
[plugins-link]:https://www.truenas.com/plugins/
[plugins-shield]:https://img.shields.io/badge/TrueNAS%20CORE-Community%20Plugin-blue?logo=TrueNAS&style=for-the-badge

<!-- CIRRUS CI RESULTS -->
[results-12.2]:https://cirrus-ci.com/github/tprelog/truenas-plugin-index/12.2-RELEASE
[results-13.0]:https://cirrus-ci.com/github/tprelog/truenas-plugin-index/13.0-RELEASE

[esphome-12.2]:https://img.shields.io/cirrus/github/tprelog/truenas-plugin-index/12.2-RELEASE?task=esphome-12-2&label=12.2-RELEASE&logo=FreeBSD&logoColor=red&style=plastic
[esphome-13.0]:https://img.shields.io/cirrus/github/tprelog/truenas-plugin-index/13.0-RELEASE?task=esphome-13-0&label=13.0-RELEASE&logo=FreeBSD&logoColor=red&style=plastic

[1]: https://esphome.io/

# iocage-esphome

Artifact file(s) for [ESPHome][1]

[![x][plugins-shield]][plugins-link]

[![x][esphome-12.2]][results-12.2]

[![x][esphome-13.0]][results-13.0]

:warning: **This plugin is not actively maintained** - At this time I am no longer using TrueNAS CORE or any iocage jails. As a consequence I may not be aware of, and proactively fixing any issues that could arise. If you're having trouble with the installation of this plugin you can still open an issue and I will do my best to help. While no further development is currently planned, I will continue trying to support this plugin for as long as it remains feasible.

NAME | SERVICE | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: |
ESPHome | esphome | 6052 | esphome | /var/db/esphome

#### Flashing over USB is not supported on TrueNAS CORE

*There is currently no USB detection for device flashing on TrueNAS CORE*. You can create, compile and download the initial firmware using ESPHome, but you will need to use [ESP Web Tools](https://esphome.github.io/esp-web-tools/) or [ESPHome-Flasher](https://github.com/esphome/esphome-flasher#esphome-flasher) on a separate computer for the initial flash. Once the device is connected to your network you will be able to manage it and flash future firmwares using the ESPHome OTA process from TrueNAS.
