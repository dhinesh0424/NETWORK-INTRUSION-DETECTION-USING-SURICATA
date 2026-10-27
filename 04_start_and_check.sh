#!/usr/bin/env bash
# Start Suricata and show basic health information.
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }
systemctl enable --now suricata
sleep 5
systemctl --no-pager status suricata | head -n 12
echo "--- log files ---"
ls -l /var/log/suricata/
echo "--- last stats ---"
grep -E "capture.kernel_(packets|drops)|detect.alert" /var/log/suricata/stats.log | tail -n 3 || true
