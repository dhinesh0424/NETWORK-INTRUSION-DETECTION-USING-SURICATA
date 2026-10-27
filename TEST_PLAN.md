# Test plan
| # | Action (Tester VM) | Expected detection |
|---|--------------------|--------------------|
| 1 | `ping -c 4 <target>` | SID 1000001, 4 alerts |
| 2 | `ssh <user>@<target>` | SID 1000002 |
| 3 | `sudo nmap -sS <target>` | Emerging Threats scan alerts, many SYN events |
| 4 | `sudo nmap -sV <target>` | Scan / service-probe alerts |
| 5 | `curl http://testmynids.org/uid/index.html` | "id check returned root" signature (needs internet) |

Record for each alert: time, source, destination, signature, severity. Attach screenshots.
