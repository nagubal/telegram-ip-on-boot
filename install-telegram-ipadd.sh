#!/bin/bash

if [[ $EUID -eq 0 ]];then
  echo "::: You are root."
else
  # Check if it is actually installed
  # If it isn't, exit because the install cannot complete
  if [[ $(dpkg-query -s sudo) ]];then
    export SUDO="sudo"
  else
    echo "::: Please install sudo or run this as root."
    exit 1
  fi
fi

TELEGRAM_IPADDR_SCRIPT=/usr/local/bin/telegram-ipaddr.sh
TELEGRAM_IPADDR_SERVICE=/etc/systemd/system/telegram-ipaddr.service


echo "Installation du script $TELEGRAM_IPADDR_SCRIPT"
$SUDO tee $TELEGRAM_IPADDR_SCRIPT >/dev/null <<'EOF'
#!/bin/bash

if [[ -z "${TELEGRAM_TOKEN}" ]]; then
  echo "The TELEGRAM_TOKEN environment variable must be set" 1>&2
  exit 1
fi

if [[ -z "${TELEGRAM_CHAT_ID}" ]]; then
  echo "The TELEGRAM_CHAT_ID environment variable must be set" 1>&2
  exit 1
fi

URL="https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage"
SHOW_IP_PATTERN="^[ewr].*|^lt.*|^umts.*"

function get_ip_addresses() {
  local ips=()
  for f in /sys/class/net/*; do
    local intf=$(basename $f)
    # match only interface names starting with e (Ethernet), br (bridge), w (wireless), r (some Ralink drivers use ra<number> format)
    if [[ $intf =~ $SHOW_IP_PATTERN ]]; then
      local tmp=$(ip -4 addr show dev $intf | awk '/inet/ {print $2}' | cut -d'/' -f1)
      # add both name and IP - can be informative but becomes ugly with long persistent/predictable device names
      [[ -n $tmp ]] && ips+=("*$intf*: $tmp")
      # add IP only
      #[[ -n $tmp ]] && ips+=("$tmp")
    fi
  done
  echo "${ips[@]}"
} # get_ip_addresses


hostname=`/bin/hostname`
ip_address=$(get_ip_addresses &)
MESSAGE="$(echo -e "\U1F4A1") Le serveur *$hostname* est prêt. $(get_ip_addresses &)"

curl -s -X POST $URL -d chat_id=${TELEGRAM_CHAT_ID} -d parse_mode=markdown -d text="$MESSAGE" >/dev/null
EOF

$SUDO chmod a+x $TELEGRAM_IPADDR_SCRIPT
echo -e "\u2714 Script $TELEGRAM_IPADDR_SCRIPT installé"

echo "Installation du service $TELEGRAM_IPADDR_SERVICE"
$SUDO tee $TELEGRAM_IPADDR_SERVICE >/dev/null <<'EOF'
[Unit]
Description=Envoie les adresses IP du serveur au démarrage
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
#Environment=TELEGRAM_CHAT_ID=
#Environment=TELEGRAM_TOKEN=
ExecStart=/usr/local/bin/telegram-ipaddr.sh

[Install]
WantedBy=multi-user.target
EOF

$SUDO systemctl daemon-reload
$SUDO systemctl enable telegram-ipaddr.service
echo -e "\u2714 Service $TELEGRAM_IPADDR_SERVICE installé et activé"

echo -e "\u2714 telegram-ipaddr a été installé."
echo -e "\u26A0 Les variables d'environnement TELEGRAM_TOKEN et TELEGRAM_CHAT_ID doivent être définies: sudo systemctl edit telegram-ipaddr.service"
