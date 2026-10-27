#!/usr/bin/env python3
"""Summarise Suricata alerts from eve.json (standard library only).

Usage:
    python3 analyze_alerts.py /var/log/suricata/eve.json
    python3 analyze_alerts.py eve.json --csv alerts.csv
"""
import argparse
import csv
import json
import sys
from collections import Counter


def load_alerts(path):
    alerts, bad = [], 0
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except json.JSONDecodeError:
                bad += 1
                continue
            if ev.get("event_type") == "alert":
                alerts.append(ev)
    return alerts, bad


def row(ev):
    a = ev.get("alert", {})
    return {
        "time": ev.get("timestamp", ""),
        "src_ip": ev.get("src_ip", ""),
        "src": f'{ev.get("src_ip", "")}:{ev.get("src_port", "")}',
        "dest": f'{ev.get("dest_ip", "")}:{ev.get("dest_port", "")}',
        "proto": ev.get("proto", ""),
        "sid": a.get("signature_id", ""),
        "signature": a.get("signature", ""),
        "severity": a.get("severity", ""),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("eve", help="path to eve.json")
    ap.add_argument("--csv", help="write all alerts to this CSV file")
    ap.add_argument("--top", type=int, default=10, help="rows in top-N tables")
    args = ap.parse_args()

    alerts, bad = load_alerts(args.eve)
    rows = [row(a) for a in alerts]
    print(f"Total alerts: {len(rows)}" + (f"  (skipped {bad} unreadable lines)" if bad else ""))
    if not rows:
        return 0

    def top(title, key):
        print(f"\n{title}")
        for k, n in Counter(r[key] for r in rows).most_common(args.top):
            print(f"  {n:5d}  {k}")

    top("Top signatures", "signature")
    top("Top source addresses", "src_ip")
    top("Alerts by severity (1 = high)", "severity")
    top("Alerts by protocol", "proto")
    print("\nFirst / last alert:", rows[0]["time"], "/", rows[-1]["time"])

    if args.csv:
        with open(args.csv, "w", newline="", encoding="utf-8") as fh:
            w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
            w.writeheader()
            w.writerows(rows)
        print(f"\nWrote {len(rows)} rows to {args.csv}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
