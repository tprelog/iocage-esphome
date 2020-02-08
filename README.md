# iocage-esphome
Artifact file(s) for ESPHome (python virtualenv) on FreeNAS 11

**The current release is intended for FreeNAS 11.3 but should work with FreeNAS-11.2-U7 or later**

- This will create an 11.3-RELEASE iocage-jail for ESPHome on FreeNAS 11.x
- This will install ESPHome in a Python virtualenv
    - ESPHome *was created by request and with the help of @CyanoFresh*

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
ESPHome | esphome | /usr/local/srv/esphome | 6052 | esphome | /var/db/esphome


##### USB devices are not supported in ESPHome on FreeNAS

*There is currently no USB detection for device flashing on FreeNAS*. You can create, compile and download the initial firmware using ESPHome on FreeNAS. *You will need to use esphomeflasher on a seperate computer for the initial flash*. After the initial flash and your device is connected to your network, you will be able to manage and flash future firmwares using the ESPHome OTA process.

---

## Installing ESPHome

#### plugin-jail

- *Coming Soon* -- FreeNAS 11.3 Community Plugin
- The plugin-jail is *only available for FreeNAS 11.3*

```bash
iocage fetch -P esphome -g https://github.com/tprelog/freenas-plugin-index.git
```
