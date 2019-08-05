# telegram-ip-on-boot
Sends the server IP addresses to Telegram on boot
## Installation
``install-telegram-ip-on-boot.sh``

## Configuration
You must define the TELEGRAM_CHAT_ID and TELEGRAM_TOKEN environment variables for the telegram-ip-on-boot service:
``sudo systemctl edit telegram-ip-on-boot.service``

and paste the following content, using your Telegram Bot Token and Chat ID
```
[Service]
Environment=TELEGRAM_CHAT_ID=123456
Environment=TELEGRAM_TOKEN=456789:XXXXXXXXXXX
```

## Test
``sudo systemctl start telegram-ip-on-boot.service``

You should receive the server IP addresses on the specified Telegram chat.
Otherwise check for errors: 

``sudo systemctl status telegram-ip-on-boot.service``
