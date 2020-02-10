# iocage-esphome
Artifact file(s) for [ESPHome][1] (python virtualenv)

### This is a [FreeNAS Community Plugin][2]

**The current release is intended for FreeNAS 11.3 but should work with FreeNAS 11.2-U7 or later**

- This will create an 11.3-RELEASE iocage-jail for [ESPHome][1]
- This will install ESPHome in a python virtualenv
    - *This FreeNAS plugin was created by request and with the help of @CyanoFresh*

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
ESPHome | esphome | /usr/local/srv/esphome | 6052 | esphome | /var/db/esphome


##### USB devices are not supported in ESPHome on FreeNAS

*There is currently no USB detection for device flashing on FreeNAS*. You can create, compile and download the initial firmware using ESPHome on FreeNAS. *You will need to use esphomeflasher on a seperate computer for the initial flash*. After the initial flash and your device is connected to your network, you will be able to manage and flash future firmwares using the ESPHome OTA process.

---

#### Installation

**ESPHome is available from the Community Plugins page on FreeNAS 11.3**
- *Coming Soon* -- FreeNAS 11.3 Community Plugin

![img][FreeNAS_plugins]

###### Install it now using the FreeNAS console

```bash
iocage fetch -P esphome -g https://github.com/tprelog/freenas-plugin-index.git
```

---

**FreeNAS 11.2-U7**
<details><summary>Click Here</summary>
<p>

##### plugin-jail

*The 11.3-RELEASE should work on FreeNAS 11.2-U7 or later*

It is possible to install this plugin on FreeNAS 11.2-U7 using the console.

```bash
wget -O /tmp/esphome.json https://raw.githubusercontent.com/tprelog/freenas-plugin-index/11.3-RELEASE/esphome.json
iocage fetch -P dhcp=on vnet=on vnet_default_interface=auto bpf=yes boot=on -n /tmp/esphome.json --branch 11.3-RELEASE
```

</p>
</details>


---

###### Current artifact files can be found in the [11.3-RELEASE branch][4]

[FreeNAS_plugins]: _img/FreeNAS_esphome.png

[1]: https://esphome.io/
[2]: https://www.freenas.org/plugins/
[3]: https://github.com/tprelog/freenas-plugin-index
[4]: https://github.com/tprelog/iocage-esphome/tree/11.3-RELEASE
