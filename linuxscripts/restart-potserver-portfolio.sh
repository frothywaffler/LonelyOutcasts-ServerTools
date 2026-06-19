#!/bin/bash

# Path of Titans Automated Restart Script
# Portfolio-safe example version
# This script warns players, restarts the server service, clears stuck processes,
# reloads Creator Mode, and restarts helper scripts.

LOG="$HOME/restart_potserver.log"

{
echo "========================================"
echo "Restart started: $(date)"

rconclt pot announce "SERVER NOTICE: Automatic restart in 5 minutes. Please finish up and prepare to safe log."
sleep 240

rconclt pot announce "SERVER NOTICE: Automatic restart in 1 minute. Please safe log now. You may reconnect shortly after restart."
sleep 60

echo "Stopping game server service..."
systemctl stop potserver
sleep 10

echo "Force killing leftover Path of Titans processes..."
pkill -9 -f PathOfTitansServer-Linux-Shipping
pkill -9 -f PathOfTitansServer.sh
sleep 5

echo "Checking ports after cleanup..."
ss -tulpn | grep -E 'GAME_PORT_1|GAME_PORT_2|QUERY_PORT_1|QUERY_PORT_2' || echo "Ports clear."

echo "Starting game server service..."
systemctl start potserver
sleep 60

echo "Loading Creator Mode..."
rconclt pot LoadCreatorMode MAP_NAME_REDACTED
sleep 10

echo "Restarting helper scripts..."
pkill -f "$HOME/tpcommands.sh"
pkill -f "$HOME/marksloop.sh"
sleep 3

nohup "$HOME/tpcommands.sh" > "$HOME/tpcommands.log" 2>&1 &
nohup "$HOME/marksloop.sh" > "$HOME/marksloop.log" 2>&1 &

echo "Final service status:"
systemctl status potserver --no-pager

echo "Server process check:"
ps -ef | grep PathOfTitansServer-Linux-Shipping | grep -v grep

echo "Port check:"
ss -tulpn | grep -E 'GAME_PORT_1|GAME_PORT_2|QUERY_PORT_1|QUERY_PORT_2' || echo "No ports found."

echo "Helper script check:"
ps aux | egrep 'tpcommands|marksloop' | grep -v grep

echo "Restart finished: $(date)"
echo "========================================"
} >> "$LOG" 2>&1
