#!/bin/bash

# Path of Titans Community Server Teleport & Timeout System
# Portfolio-safe example version
# Sensitive values such as staff names, coordinates, and private paths have been replaced.

LOG="/path/to/PathOfTitans.log"
BLOCKLIST="$HOME/tpblocked.txt"
TIMEOUTS="$HOME/timeouts.txt"

# Staff members allowed to issue timeout commands.
# Real staff usernames removed for public portfolio.
TIMEOUT_ADMINS="admin_user_1|admin_user_2|admin_user_3"

# Timeout location removed for privacy/security.
TIMEOUT_COORDS="(X=REDACTED,Y=REDACTED,Z=REDACTED)"

tp_retry() {
    for i in {1..4}; do
        rconclt pot teleport "$@"
        sleep 0.5
    done
}

jail_enforcer() {
    while true; do
        NOW=$(date +%s)

        while IFS='|' read -r NAME DISPLAY EXPIRES MINUTES; do
            [ -z "$NAME" ] && continue
            [ "$NOW" -ge "$EXPIRES" ] && continue

            tp_retry "$DISPLAY" "$TIMEOUT_COORDS"
        done < "$TIMEOUTS" 2>/dev/null

        sleep 10
    done
}

jail_enforcer &

clean_timeouts() {
    NOW=$(date +%s)
    TMP="$TIMEOUTS.tmp"
    > "$TMP"

    while IFS='|' read -r NAME DISPLAY EXPIRES MINUTES; do
        [ -z "$NAME" ] && continue

        if [ "$NOW" -lt "$EXPIRES" ]; then
            echo "$NAME|$DISPLAY|$EXPIRES|$MINUTES" >> "$TMP"
            grep -qx "$NAME" "$BLOCKLIST" 2>/dev/null || echo "$NAME" >> "$BLOCKLIST"
        else
            sed -i "/^$NAME$/d" "$BLOCKLIST" 2>/dev/null
            echo "$(date): timeout expired for $NAME" >> "$HOME/tpcommands.log"
        fi
    done < "$TIMEOUTS" 2>/dev/null

    mv "$TMP" "$TIMEOUTS"
}

set_timeout() {
    NAME="$1"
    DISPLAY="$2"
    MINUTES="$3"
    NOW=$(date +%s)
    EXPIRES=$((NOW + MINUTES * 60))

    grep -v "^$NAME|" "$TIMEOUTS" 2>/dev/null > "$TIMEOUTS.tmp"
    echo "$NAME|$DISPLAY|$EXPIRES|$MINUTES" >> "$TIMEOUTS.tmp"
    mv "$TIMEOUTS.tmp" "$TIMEOUTS"

    grep -qx "$NAME" "$BLOCKLIST" 2>/dev/null || echo "$NAME" >> "$BLOCKLIST"
}

get_timeout_line() {
    grep "^$1|" "$TIMEOUTS" 2>/dev/null
}

extend_timeout_relog() {
    NAME="$1"
    DISPLAY="$2"
    LINE=$(get_timeout_line "$NAME")
    [ -z "$LINE" ] && return

    OLDMINUTES=$(echo "$LINE" | awk -F'|' '{print $4}')
    NEWMINUTES=$((OLDMINUTES + 1))
    NOW=$(date +%s)
    NEWEXPIRES=$((NOW + NEWMINUTES * 60))

    grep -v "^$NAME|" "$TIMEOUTS" 2>/dev/null > "$TIMEOUTS.tmp"
    echo "$NAME|$DISPLAY|$NEWEXPIRES|$NEWMINUTES" >> "$TIMEOUTS.tmp"
    mv "$TIMEOUTS.tmp" "$TIMEOUTS"

    grep -qx "$NAME" "$BLOCKLIST" 2>/dev/null || echo "$NAME" >> "$BLOCKLIST"

    tp_retry "$DISPLAY" "$TIMEOUT_COORDS"
    rconclt pot ServerMute "$DISPLAY" "${NEWMINUTES}m" Timeout Relogging
    rconclt pot announce "$DISPLAY attempted to avoid timeout by relogging. Their timeout was restarted and extended."
}

tail -F "$LOG" | while read line
do
    clean_timeouts

    LOGINPLAYER=$(echo "$line" | sed -n 's/.*\[RegisterClient\] PlayerName: \([^ (]*\).*/\1/p')

    if [ -n "$LOGINPLAYER" ]; then
        LOGINLOWER=$(echo "$LOGINPLAYER" | tr '[:upper:]' '[:lower:]')
        if get_timeout_line "$LOGINLOWER" >/dev/null; then
            extend_timeout_relog "$LOGINLOWER" "$LOGINPLAYER"
        fi
        continue
    fi

    PLAYER=$(echo "$line" | sed -n 's/.*PlayerName: \(.*\) Message:.*/\1/p')
    MESSAGE=$(echo "$line" | sed -n 's/.*Message: \([^ ]*\).*/\1/p' | tr '[:upper:]' '[:lower:]')
    FULLMSG=$(echo "$line" | sed -n 's/.*Message: //p')

    [ -z "$PLAYER" ] && continue
    [ -z "$MESSAGE" ] && continue

    PLAYERLOWER=$(echo "$PLAYER" | tr '[:upper:]' '[:lower:]')

    if echo "$FULLMSG" | grep -qi '^timeout '; then
        echo "$TIMEOUT_ADMINS" | tr '|' '\n' | grep -Fxq "$PLAYERLOWER"
        if [ $? -eq 0 ]; then
            TARGET=$(echo "$FULLMSG" | awk '{print $2}')
            MINUTES=$(echo "$FULLMSG" | awk '{print $3}')

            if echo "$MINUTES" | grep -Eq '^[0-9]+$'; then
                TARGETLOWER=$(echo "$TARGET" | tr '[:upper:]' '[:lower:]')

                set_timeout "$TARGETLOWER" "$TARGET" "$MINUTES"
                tp_retry "$TARGET" "$TIMEOUT_COORDS"

                rconclt pot announce "$TARGET has been placed in timeout. Teleport commands are blocked until timeout ends."
            fi
        fi
        continue
    fi

    if echo "$FULLMSG" | grep -qi '^untimeout '; then
        echo "$TIMEOUT_ADMINS" | tr '|' '\n' | grep -Fxq "$PLAYERLOWER"
        if [ $? -eq 0 ]; then
            TARGET=$(echo "$FULLMSG" | awk '{print $2}')
            TARGETLOWER=$(echo "$TARGET" | tr '[:upper:]' '[:lower:]')

            grep -v "^$TARGETLOWER|" "$TIMEOUTS" 2>/dev/null > "$TIMEOUTS.tmp"
            mv "$TIMEOUTS.tmp" "$TIMEOUTS"

            sed -i "/^$TARGETLOWER$/d" "$BLOCKLIST" 2>/dev/null

            rconclt pot announce "$TARGET has been released from timeout."
        fi
        continue
    fi

    if grep -qx "$PLAYERLOWER" "$BLOCKLIST" 2>/dev/null; then
        case "$MESSAGE" in
            tp*) tp_retry "$PLAYER" "$TIMEOUT_COORDS"; continue ;;
        esac
    fi

    case "$MESSAGE" in
        tpzone1) tp_retry "$PLAYER" "(X=REDACTED,Y=REDACTED,Z=REDACTED)" ;;
        tpzone2) tp_retry "$PLAYER" "(X=REDACTED,Y=REDACTED,Z=REDACTED)" ;;
        tpzone3) tp_retry "$PLAYER" "(X=REDACTED,Y=REDACTED,Z=REDACTED)" ;;
        tpzone4) tp_retry "$PLAYER" "(X=REDACTED,Y=REDACTED,Z=REDACTED)" ;;
        tpzone5) tp_retry "$PLAYER" "NamedMapLocation" ;;
    esac
done
