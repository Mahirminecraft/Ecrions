#!/bin/bash
BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
CHAT_ID="${TELEGRAM_CHAT_ID}"
PORT="$PORT"
DOMAIN="ecrion.ddns.net"

OFFSET_FILE="last_update.offset"
touch $OFFSET_FILE

while true; do
    OFFSET=$(cat $OFFSET_FILE)
    UPDATES=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=$OFFSET")

    for row in $(echo "$UPDATES" | jq -r '.result[] | @base64'); do
        _jq() {
            echo ${row} | base64 --decode | jq -r ${1}
        }

        UPDATE_ID=$(_jq '.update_id')
        MESSAGE=$(_jq '.message.text')

        if [[ "$MESSAGE" == "/ip" || "$MESSAGE" == "/port" ]]; then
            curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
                -d chat_id="$CHAT_ID" \
                -d text="$DOMAIN:$PORT"
        fi

        echo $((UPDATE_ID + 1)) > $OFFSET_FILE
    done

    sleep 5
done
