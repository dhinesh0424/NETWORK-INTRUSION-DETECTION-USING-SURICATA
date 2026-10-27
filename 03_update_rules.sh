#!/usr/bin/env bash
# Download Emerging Threats Open rules and reload Suricata.
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }
suricata-update
suricata -T -c /etc/suricata/suricata.yaml -v
if pidof suricata >/dev/null; then kill -USR2 "$(pidof suricata)" && echo "Rules reloaded."; fi
