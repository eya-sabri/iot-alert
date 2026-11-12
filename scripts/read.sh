#!/bin/bash
SERIAL_PORT="/dev/ttyUSB1"
JSON_FILE="/opt/iot-alert/last.json"

echo "[INFO] Lecture temps réel du port $SERIAL_PORT ..."

stty -F $SERIAL_PORT 115200 raw -echo

while true; do
    if read -r LINE < "$SERIAL_PORT"; then
        # ignore les lignes vides
        [[ -z "$LINE" ]] && continue

        # affiche reçu et met à jour last.json
        echo "[RECU] $LINE"
        echo "$LINE" > "$JSON_FILE"
    fi
done

