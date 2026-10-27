# Troubleshooting
| Symptom | Fix |
|---------|-----|
| Service will not start | `sudo suricata -T -c /etc/suricata/suricata.yaml -v`; read `/var/log/suricata/suricata.log` |
| No alerts for ping | Enable promiscuous mode (VirtualBox adapter: Allow All); check interface and HOME_NET |
| New rule not firing | Reload: `sudo kill -USR2 $(pidof suricata)` |
| eve.json empty | Set `eve-log: enabled: yes` |
| Too many alerts | Add SIDs to `/etc/suricata/disable.conf`, run `suricata-update` |
| Packet drops | Give the sensor more vCPU/RAM; check `stats.log` |
