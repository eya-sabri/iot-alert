#!/bin/bash
# /opt/iot-alert/alert.sh

set -e

# --------- CONFIG----------
JSON_FILE="/opt/iot-alert/last.json"
TEMP_MAX=18.0
HUM_MAX=60
EMAIL_TO="votre-email@exemple.com"   # à adapter
EMAIL_FROM="iot-alert@localhost"
# ----------------------------------------------------

# Si le fichier n'existe pas ou est vide, on quitte proprement
if [[ ! -s "$JSON_FILE" ]]; then
  exit 0
fi

# Extraction des valeurs temp et hum (nettoyage des espaces et retours à la ligne)
extract_number() {
  local key="$1"
  grep -o "\"$key\"[[:space:]]*:[[:space:]]*[-0-9.eE+]\+" "$JSON_FILE" 2>/dev/null \
    | sed -E "s/.*:[[:space:]]*([+-]?[0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?).*/\1/" \
    | tr -d '[:space:]' \
    | head -n1
}

TEMP_RAW=$(extract_number temp || true)
HUM_RAW=$(extract_number hum || true)

# Si on n'a rien, on sort
if [[ -z "$TEMP_RAW" && -z "$HUM_RAW" ]]; then
  exit 0
fi

# Forcer format numérique
TEMP=$(printf "%f" "$TEMP_RAW" 2>/dev/null || echo "")
HUM=$(printf "%f" "$HUM_RAW" 2>/dev/null || echo "")


ALERT_MSG=""

# Comparaisons float via awk
if [[ -n "$TEMP" ]]; then
  if awk -v t="$TEMP" -v lim="$TEMP_MAX" 'BEGIN{exit !(t>lim)}'; then
    ALERT_MSG+="Température élevée: ${TEMP}°C (seuil ${TEMP_MAX}°C)\n"
  fi
fi

if [[ -n "$HUM" ]]; then
  if awk -v h="$HUM" -v lim="$HUM_MAX" 'BEGIN{exit !(h>lim)}'; then
    ALERT_MSG+="Humidité élevée: ${HUM}% (seuil ${HUM_MAX}%)\n"
  fi
fi

# Si alerte, envoi mail
if [[ -n "$ALERT_MSG" ]]; then
  SUBJECT="ALERTE IOT: seuil dépassé sur $(hostname)"
  BODY="Alerte détectée à $(date -Iseconds)\n\nDétails:\n$ALERT_MSG\nFichier: $JSON_FILE\n\n--\nIoT Alert System"

  if command -v mail >/dev/null 2>&1; then
    printf "%b" "$BODY" | mail -s "$SUBJECT" -a "From: $EMAIL_FROM" "$EMAIL_TO"
  else
    # fallback simple si mail absent
    printf "%b" "Subject: $SUBJECT\nFrom: $EMAIL_FROM\nTo: $EMAIL_TO\n\n$BODY" | sendmail -t
  fi
fi

exit 0

