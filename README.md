# telegram-ip-on-boot
Sends the server IP addresses to Telegram on boot

## Why ?
I have a few headless servers (Raspberry Pi, Orange Pi, nuc, etc.), and I want be notified when it is online after a reboot, or when setting up a new one. 


## Installation
``install-telegram-ip-on-boot.sh``

It creates a bash script and a systemd service which is enabled
```
/usr/local/bin/telegram-ip-on-boot.sh
/etc/systemd/system/telegram-ip-on-boot.service
```

## Configuration
You must define the TELEGRAM_CHAT_ID and TELEGRAM_TOKEN environment variables for the telegram-ip-on-boot service; it can be done with systemd drop-in (/etc/systemd/system/telegram-ip-on-boot.service.d/override.conf file):
```
sudo systemctl edit telegram-ip-on-boot.service
```

and paste the following content, using your Telegram Bot Token and Chat ID
```
[Service]
Environment=TELEGRAM_CHAT_ID=123456
Environment=TELEGRAM_TOKEN=456789:XXXXXXXXXXX
```

If needed, you can also add/change other options in this drop-in, such as:
```
[Unit]
# Run after the wireguard has started
After=wg-quick@wg0.service

[Service]
Environment=TELEGRAM_CHAT_ID=123456
Environment=TELEGRAM_TOKEN=456789:XXXXXXXXXXX
```

## Test
``sudo systemctl start telegram-ip-on-boot.service``

You should receive the server IP addresses on the specified Telegram chat.
Otherwise check for errors: 

``sudo systemctl status telegram-ip-on-boot.service``

## Uninstall
```
sudo systemctl disable telegram-ip-on-boot.service
sudo rm /etc/systemd/system/telegram-ip-on-boot.service
sudo rm -rf /etc/systemd/system/telegram-ip-on-boot.service.d/
sudo rm /usr/local/bin/telegram-ip-on-boot.sh
```
