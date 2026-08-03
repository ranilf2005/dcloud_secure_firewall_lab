# Deep-dive diagnostics 

1) Packet-tracer (simulate decision path)
FTD CLI:
```graphql
packet-tracer input inside icmp 192.168.5.10 8 0 1.1.1.1 detailed
packet-tracer input inside tcp 192.168.5.10 12345 80 142.250.70.36 detailed   # example HTTP to Google IP
```

Look for where it’s allowed/denied (NAT, Route Lookup, Access-Control, etc.).



2) Real packet captures (inside & outside)
(ASA-style captures on many FTD versions)
```python
capture capIN type raw-data interface inside match ip host 192.168.5.10 any
capture capOUT type raw-data interface outside match ip any any
# generate traffic from the PC, then:
show capture capIN
show capture capOUT
no capture capIN
no capture capOUT
```

Interpretation:
•	Seen on inside, not on outside → ACP or NAT/routing problem.
•	Seen on outside with translated SRC = 198.18.1.4 → NAT is working; check upstream/return path.
•	Replies seen on outside but not on inside → return blocked (ACP), asymmetric routing, or inspection/state issue.


3) Connection/Xlate tables
```nginx
show conn address 192.168.5.10
show xlate | include 192.168.5.10
```

Expect a translated (xlated) entry and an active connection when traffic flows.

4) Drop reason (very useful)
```sql
show asp drop
```

Quick command crib (FTD CLI)

```pgsql
show interface ip brief
show route
show arp
show nat detail
show xlate | include 192.168.5.
show conn address 192.168.5.10
packet-tracer input inside icmp 192.168.5.10 8 0 1.1.1.1 detailed
capture capIN type raw-data interface inside match ip host 192.168.5.10 any
capture capOUT type raw-data interface outside match ip any any
show capture capIN
show capture capOUT
no capture capIN
no capture capOUT
show asp drop
```
