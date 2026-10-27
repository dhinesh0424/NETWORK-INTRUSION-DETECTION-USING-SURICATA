#!/usr/bin/env bash
# Usage: sudo ./02_configure.sh <interface> <home_net_cidr>
# Example: sudo ./02_configure.sh enp0s3 192.168.56.0/24
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }
IFACE="${1:?interface required, e.g. enp0s3}"
HOMENET="${2:?home net required, e.g. 192.168.56.0/24}"
YAML=/etc/suricata/suricata.yaml
RULES_DIR=/var/lib/suricata/rules
HERE="$(cd "$(dirname "$0")/.." && pwd)"

ip link show "$IFACE" >/dev/null || { echo "Interface $IFACE not found"; exit 1; }
cp -n "$YAML" "$YAML.orig"

# HOME_NET
sed -i -E "s|^(\s*HOME_NET:).*|\1 \"[${HOMENET}]\"|" "$YAML"
# af-packet interface (first occurrence)
sed -i -E "0,/^(\s*- interface:).*/s||\1 ${IFACE}|" "$YAML"

mkdir -p "$RULES_DIR"
cp "$HERE/rules/local.rules" "$RULES_DIR/local.rules"
if ! grep -qE '^\s*-\s*local.rules' "$YAML"; then
  sed -i -E '0,/^(\s*-\s*suricata.rules)/s||\1\n  - local.rules|' "$YAML"
fi
[[ -f /etc/suricata/disable.conf ]] || cp "$HERE/config/disable.conf" /etc/suricata/disable.conf

# Allow the sensor NIC to see all traffic (needed on virtual switches)
ip link set "$IFACE" promisc on || true
echo "Configured: interface=$IFACE HOME_NET=$HOMENET"
echo "Check eve-log is enabled:  grep -n -A3 'eve-log' $YAML"
suricata -T -c "$YAML" -v
