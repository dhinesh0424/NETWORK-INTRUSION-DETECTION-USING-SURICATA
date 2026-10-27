#!/usr/bin/env bash
# Run on the TESTER VM. Generates controlled traffic towards the target.
# Usage: ./05_run_tests.sh 192.168.56.103
# Safety: only private (RFC1918) targets are accepted.
set -uo pipefail
TARGET="${1:?target IP required}"

is_private() {
  [[ "$1" =~ ^10\. ]] || [[ "$1" =~ ^192\.168\. ]] || [[ "$1" =~ ^172\.(1[6-9]|2[0-9]|3[01])\. ]]
}
is_private "$TARGET" || { echo "Refusing: $TARGET is not a private lab address."; exit 1; }
echo "Lab-only tests against $TARGET - make sure you own this machine."
read -rp "Type YES to continue: " ok; [[ "$ok" == "YES" ]] || exit 1

echo "[Test 1] ICMP ping";         ping -c 4 "$TARGET"; sleep 3
echo "[Test 2] SSH attempt";       timeout 5 ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no "nobody@$TARGET" true 2>/dev/null; sleep 3
echo "[Test 3] Nmap SYN scan";     sudo nmap -sS "$TARGET"; sleep 5
echo "[Test 4] Nmap service scan"; sudo nmap -sV "$TARGET"; sleep 5
echo "[Test 5] Test signature (needs internet via NAT adapter)"
curl -m 8 -s http://testmynids.org/uid/index.html || echo "(no internet - skipped)"
echo "Done. Check fast.log / eve.json on the sensor."
