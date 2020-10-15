# iocage-esphome
Artifact file(s) for [ESPHome][1] (python virtualenv)

*This FreeNAS plugin was created by request and with the help of @CyanoFresh*

- This will create an iocage-jail for [ESPHome][1]
- ESPHome will be installed in a python virtualenv

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
ESPHome | esphome | /usr/local/srv/esphome | 6052 | esphome | /var/db/esphome

#### USB devices are not supported in ESPHome on FreeNAS

*There is currently no USB detection for device flashing on FreeNAS*. You can create, compile and download the initial firmware using ESPHome on FreeNAS. *You will need to use esphomeflasher on a seperate computer for the initial flash*. After the initial flash and your device is connected to your network, you will be able to manage and flash future firmwares using the ESPHome OTA process.
