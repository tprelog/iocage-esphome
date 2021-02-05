# iocage-esphome

Artifact file(s) for [ESPHome][1] (python virtualenv)

:warning: This plugin is not actively maintained

- ESPHome will be installed in a Python Virtualenv

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
ESPHome | esphome | /usr/local/srv/esphome | 6052 | esphome | /var/db/esphome

#### USB devices are not supported in ESPHome on FreeNAS

*There is currently no USB detection for device flashing on FreeNAS*. You can create, compile and download the initial firmware using ESPHome on FreeNAS. *You will need to use esphomeflasher on a seperate computer for the initial flash*. After the initial flash and your device is connected to your network, you will be able to manage and flash future firmwares using the ESPHome OTA process.

[1]: https://esphome.io/
