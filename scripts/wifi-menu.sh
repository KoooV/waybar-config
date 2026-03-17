#!/usr/bin/env bash

# Получаем кэшированный список доступных сетей мгновенно (--rescan no)
SSID=$(nmcli -t -f SSID device wifi list --rescan no | grep -v "^$" | sort -u | fuzzel --dmenu --prompt "Wi-Fi   " --lines 10)

# Если ничего не выбрали (нажали Esc), выходим
[ -z "$SSID" ] && exit 0

# Проверяем, подключались ли мы к этой сети раньше
SAVED=$(nmcli -t -f NAME connection show | grep -w "$SSID")

if [ -n "$SAVED" ]; then
    notify-send "Wi-Fi" "Подключение к $SSID..."
    nmcli connection up id "$SSID"
else
    # Запрашиваем пароль
    PASSWORD=$(echo "" | fuzzel --dmenu --password --prompt "Пароль для $SSID: ")
    [ -z "$PASSWORD" ] && exit 0
    
    notify-send "Wi-Fi" "Подключение к $SSID..."
    nmcli device wifi connect "$SSID" password "$PASSWORD"
fi

if [ $? -eq 0 ]; then
    notify-send "Wi-Fi" "Успешно подключено к $SSID"
else
    notify-send "Wi-Fi" "Ошибка подключения к $SSID"
fi
