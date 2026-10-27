#!/usr/bin/env bash
# Install Suricata from the OISF stable PPA (Ubuntu).
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo"; exit 1; }
apt-get update
apt-get install -y software-properties-common jq
add-apt-repository -y ppa:oisf/suricata-stable
apt-get update
apt-get install -y suricata
suricata -V
