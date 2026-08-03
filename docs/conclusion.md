# Conclusion

You have completed the Cisco Secure Firewall Enablement Workshop.

## What you covered

- Traced a packet through the FTD dataplane from ingress to egress.
- Configured and verified NAT, and checked the translation and connection tables.
- Built and troubleshot Access Control Policies, including the default action and logging.
- Worked through Site-to-Site and Remote Access VPN configuration and verification.
- Diagnosed traffic end to end with `packet-tracer`, captures, `show asp drop` and FMC events.
- Automated FMC configuration through its REST API.

## Troubleshooting quick reference

```nginx
show interface ip brief
show route
show nat detail
show xlate | include <host>
show conn address <host>
packet-tracer input inside icmp <src> 8 0 <dst> detailed
capture capIN type raw-data interface inside match ip host <host> any
show capture capIN
show asp drop
```

## Where to go next

- Repeat the tasks in [2 - Lab Tasks](lab-tasks.md) without the walkthrough and time yourself.
- Re-read [Theory](theory.md) and map each concept to what you saw in the CLI output.
- Work through [Deep-dive Diagnostics](deep-dive-diagnostics.md) against a scenario you break yourself.
- Extend [3 - Automation with FMC](automation-fmc.md) to push your own policy set.
