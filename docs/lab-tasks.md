# Lab Tasks

End goal of this lab tasks is to make sure LAN-B<br><br>


## Tasks summary 
Run all those tests to complete this job and understand end-to-end packet troubleshooting and successful test results.<br><br>

![ACI](./assets/acmet1.png)<br><br>

These are all the test tasks
```nginx
INSIDE TO OUTSIDE:
1. ping from 198.18.6.6 to 198.18.6.2 (ACME FTD inside interface)
2. ping from 198.18.6.6 to 198.18.2.11 (ACME Kali PC )
3. ping from 198.18.6.6 to 8.8.8.8
4. ping from 198.18.6.6 to www.google.com

OUTSIDE TO INSIDE
5. ping from 198.18.2.11 or 10 to 198.18.6.6

```

If all five of your pings are successful, then you have completed the lab. If not, let's start troubleshooting and go to the next task.<br><br>

## Tips for troubleshooting

â€¢	Check PCâ€™s IP/mask/gateway/Firewall
â€¢	Check Firewall routing, ACP, NAT<br><br>

(Optional) Write a quick web page to test in Kali â€“ index.html<br><br>

![ACI](./assets/2-1.png)<br><br>

## Lab Login Details

FMC https://198.18.2.2
username:admin
PW: dCloud123!
<br>
FMC https://198.18.1.2
username:admin
PW: Cisco@123
<br>
Windows 11:
admin / C1sco12345
<br>
Kali Linux:
kali / C1sco12345
<br>

## Task 1
Please login to both Kali PCs (Green box) hlighted in below diagram for this task.<br>
Log in to the LAN-B Kali PC, open the terminal, and run the following ping commands to check the connectivity.

![ACI](./assets/topology-acme.png)<br><br>

```nginx
1. ping 198.18.6.2 (ACME FTD inside interface)2
2. ping 198.18.2.11 (ACME Kali PC )
3. ping 8.8.8.8
4. ping www.google.com
```
<br><br>

![ACI](./assets/2-2.png)<br><br>

![ACI](./assets/2-3.png)<br><br>

 - A.	ping 198.18.6.2 (ACME FTD inside interface)<br><br>

![ACI](./assets/2-4.png)<br><br>

```nginx
1. ping 198.18.2.11 (ACME Kali PC )
2. ping 8.8.8.8
3. ping google.com
```
<br><br>


![ACI](./assets/2-5.png)<br><br>


## Task 2

Troubleshoot through FTD CLI<br><br>
SSH to FTD management IP 198.18.2.3 (Please use win11-acme windows PC to SSH to FTD using putty)<br><br>
(Pleae note: This is the optional troubleshooting through CLI; you can also do the same troubleshooting using FMC Web GUI)<br><br>

Check routing

![ACI](./assets/2-6.png)
<br><br>

Packet-tracer (simulate decision path) FTD CLI:
Look for where itâ€™s allowed/denied (NAT, Route Lookup, Access-Control, etc.).<br><br>

```graphql
> packet-tracer input inside icmp 198.18.6.6 8 0 198.18.2.11 detailed 

Phase: 1
Type: ACCESS-LIST
Subtype: 
Result: ALLOW
Elapsed time: 51923 ns
Config:
Implicit Rule
Additional Information:
 Forward Flow based lookup yields rule:
 in  id=0x149ac0317560, priority=1, domain=permit, deny=false
        hits=634, user_data=0x0, cs_id=0x0, l3_type=0x8
        src mac=0000.0000.0000, mask=0000.0000.0000
        dst mac=0000.0000.0000, mask=0100.0000.0000
        input_ifc=inside, output_ifc=any

Phase: 2
Type: ROUTE-LOOKUP
Subtype: No ECMP load balancing
Result: ALLOW
Elapsed time: 22361 ns
Config:
Additional Information:
Destination is locally connected. No ECMP load balancing.
Found next-hop 198.18.2.11 using egress ifc  outside(vrfid:0)

Phase: 3
Type: OBJECT_GROUP_SEARCH
Subtype: 
Result: ALLOW
Elapsed time: 0 ns
Config:
Additional Information:
 Source Object Group Match Count:       0
 Destination Object Group Match Count:  0
 Object Group Search:                   0

Phase: 4
Type: ACCESS-LIST
Subtype: log
Result: DROP
Elapsed time: 303 ns
Config:
access-group CSM_FW_ACL_ global
access-list CSM_FW_ACL_ advanced deny ip any any rule-id 268434432 
access-list CSM_FW_ACL_ remark rule-id 268434432: ACCESS POLICY: Policy_FTD-LAN-B - Default
access-list CSM_FW_ACL_ remark rule-id 268434432: L4 RULE: DEFAULT ACTION RULE
Additional Information:
 Forward Flow based lookup yields rule:
 in  id=0x149ac03e50c0, priority=12, domain=permit, deny=true
        hits=1710, user_data=0x149a930d6c80, cs_id=0x0, use_real_addr, flags=0x0, protocol=0
        src ip/id=0.0.0.0, mask=0.0.0.0, port=0, tag=any, ifc=any
        dst ip/id=0.0.0.0, mask=0.0.0.0, port=0, tag=any, ifc=any,, dscp=0x0, nsg_id=none
        input_ifc=any, output_ifc=any

Result:
input-interface: inside(vrfid:0)
input-status: up
input-line-status: up
output-interface: outside(vrfid:0)
output-status: up
output-line-status: up
Action: drop
Time Taken: 74587 ns
Drop-reason: (acl-drop) Flow is denied by configured rule, Drop-location: frame 0x00005611d409b518 flow (NA)/NA
> 
```
<br><br>

Checking asp drop

![ACI](./assets/2-7.png)<br><br>

Real packet captures (inside & outside) (ASA-style captures on many FTD versions)<br>
Interpretation: <br>
- Seen on inside, not on outside â†’ ACP or NAT/routing problem.
- Seen on outside with translated SRC = 198.18.2.4 â†’ NAT is working; check upstream/return path.
- Replies seen on outside but not on inside â†’ return blocked (ACP), asymmetric routing, or inspection/state issue.<br><br>

![ACI](./assets/2-8.png)<br><br>

```graphql
capture capIN type raw-data interface inside match ip host 198.18.6.6 any 
> 
> capture capOUT type raw-data interface outside match ip any 
any  any4 any6 host 
> capture capOUT type raw-data interface outside match ip any any 
```
<br><br>

![ACI](./assets/2-9.png)<br><br>

![ACI](./assets/2-10.png)<br><br>

![ACI](./assets/2-11.png)<br><br>

![ACI](./assets/2-12.png)<br><br>

Connection/Xlate tables<br>
Expect a translated (xlated) entry and an active connection when traffic flows.<br><br>

```nginx
show conn address 198.18.6.6
show xlate | include 198.18.6.6
```
<br><br>

Quick command crib (FTD CLI)<br><br>

```graphql
show interface ip brief
show route
show arp
show nat detail
show xlate | include 198.18.6.6
show conn address 198.18.6.6
packet-tracer input inside icmp 198.18.6.6 8 0 8.8.8.8 detailed
capture capIN type raw-data interface inside match ip host 198.18.6.6 any
capture capOUT type raw-data interface outside match ip any any
show capture capIN
show capture capOUT
no capture capIN
no capture capOUT
show asp drop
```
<br><br>

Checking the default ACP action, ACP and NAT<br>
Please note:<br>
 - Deaful ACP action id â€œBlockâ€<br>
 - Please make sure to check the Defualy ACP Action log configuration
 - No ACP rules configured<br>
 - No NAT rules configured<br>


![ACI](./assets/2-13.png)<br><br>

Check what are the default actions<br><br>

![ACI](./assets/2-14.png)<br><br>

Checking connection events<br>

![ACI](./assets/2-15.png)<br><br>

![ACI](./assets/2-16.png)<br><br>

![ACI](./assets/2-17.png)<br><br>

![ACI](./assets/2-18.png)<br><br>

![ACI](./assets/2-19.png)<br><br>


Enable ACP rules analysis<br><br>

![ACI](./assets/2-20.png)<br><br>

![ACI](./assets/2-21.png)<br><br>

Enable or disable event columns.<br>
Click the X to mark any of the fields.<br><br>

![ACI](./assets/2-22.png)<br><br>

![ACI](./assets/2-23.png)<br><br>

Advance search<br><br>

![ACI](./assets/2-24.png)<br><br>

Packet Tracer using GUI<br><br>

![ACI](./assets/2-25.png)<br><br>

![ACI](./assets/2-26.png)<br><br>

![ACI](./assets/2-27.png)<br><br>

Check the issue regarding packet drops and their reasons.<br><br>

![ACI](./assets/2-28.png)<br><br>


```graphql
Interface: GigabitEthernet0/1
VLAN ID: 
Protocol: ICMP
Source Type: IPv4
Source IP value: 198.18.6.6
Destination Type: IPv4
Destination IP value: 8.8.8.8
ICMP Code: 0
ICMP ID: 
ICMP Type: 8 (Echo Request)
Treat simulated packet as IPsec/SSL VPN decrypt: false
Bypass all security checks for simulated packet: false
Allow simulated packet to transmit from device: false
Select Device: FTD-LAN-B-198.18.2.3
Run trace on all cluster members: false

Device details
Name: FTD-LAN-B-198.18.2.3
Type: Device
ID: cf3467b2-c6e4-11ee-852c-b95da810329f

Phase 1
Elapsed Time: 20087 ns
Type: CAPTURE
ID: 1
Config: 
Result: ALLOW
Additional Information:  Forward Flow based lookup yields rule: in  id=0x149a6cf6fc90, priority=13, domain=capture, deny=false	hits=215, user_data=0x149ac03e98e0, cs_id=0x0, l3_type=0x0	src mac=0000.0000.0000, mask=0000.0000.0000	dst mac=0000.0000.0000, mask=0000.0000.0000	input_ifc=inside, output_ifc=any

Phase 2
Config: Implicit Rule
Elapsed Time: 20087 ns
Type: ACCESS-LIST
ID: 2
Additional Information:  Forward Flow based lookup yields rule: in  id=0x149ac0317560, priority=1, domain=permit, deny=false	hits=8079, user_data=0x0, cs_id=0x0, l3_type=0x8	src mac=0000.0000.0000, mask=0000.0000.0000	dst mac=0000.0000.0000, mask=0100.0000.0000	input_ifc=inside, output_ifc=any
Result: ALLOW

Phase 3
ID: 3
Config: 
Result: ALLOW
Type: INPUT-ROUTE-LOOKUP
Elapsed Time: 21603 ns
Subtype: Resolve Egress Interface
Additional Information: Found next-hop 198.18.2.1 using egress ifc  outside(vrfid:0)

Phase 4
Result: ALLOW
Additional Information:  Source Object Group Match Count:       0 Destination Object Group Match Count:  0 Object Group Search:                   0
Config: 
ID: 4
Elapsed Time: 0 ns
Type: OBJECT_GROUP_SEARCH

Phase 5
Result: DROP
ID: 5
Config: access-group CSM_FW_ACL_ globalaccess-list CSM_FW_ACL_ advanced deny ip any any rule-id 268434432 access-list CSM_FW_ACL_ remark rule-id 268434432: ACCESS POLICY: Policy_FTD-LAN-B - Defaultaccess-list CSM_FW_ACL_ remark rule-id 268434432: L4 RULE: DEFAULT ACTION RULE
Additional Information:  Forward Flow based lookup yields rule: in  id=0x149ac03e50c0, priority=12, domain=permit, deny=true	hits=7633, user_data=0x149a930d6c80, cs_id=0x0, use_real_addr, flags=0x0, protocol=0	src ip/id=0.0.0.0, mask=0.0.0.0, port=0, tag=any, ifc=any	dst ip/id=0.0.0.0, mask=0.0.0.0, port=0, tag=any, ifc=any,, dscp=0x0, nsg_id=none	input_ifc=any, output_ifc=any
Subtype: log
Type: ACCESS-LIST
Elapsed Time: 151 ns

Result
Output Line Status: up
Input Status: up
Drop Detail: Drop-location: frame 0x00005611d409b518 flow (NA)/NA
Input Line Status: up
Time Taken: 61928 ns
Drop Reason: (acl-drop) Flow is denied by configured rule
Output Status: up
Output Interface: outside(vrfid:0)
Action: drop
Input Interface: inside(vrfid:0)
```
<br><br>

Packet Capture using GUI<br><br>

![ACI](./assets/2-29.png)<br><br>

Save packet capture and analyses through Wireshark.<br><br>

![ACI](./assets/2-30.png)<br><br>

![ACI](./assets/2-31.png)<br><br>

![ACI](./assets/2-32.png)<br><br>

![ACI](./assets/2-33.png)<br><br>


## Task 3
Allow traffic from inside 198.18.6.6 to outside 8.8.8.8<br><br>

Check Secure Firewall configuration<br>
Login to FMC https://198.18.2.2 (admin / dCloud123!)<br>
 - Check the Interface IPs, Routing, and zones
 - Check required ACP and NAT policies<br><br>

Policies > Access control<br><br>
![ACI](./assets/2-34.png)<br><br>

Device > NAT<br><br>

![ACI](./assets/2-35.png)<br><br>

Once you have completed your Firewall configuration, make sure to Save and deploy it.<br>
(select the Ignore warning for this lab)<br><br>

![ACI](./assets/2-36.png)<br><br>

![ACI](./assets/2-37.png)<br><br>


Check the packet captures again to see the results<br><br>

![ACI](./assets/2-38.png)<br><br>

![ACI](./assets/2-39.png)<br><br>

Very important to stop the captures once you finish troubleshooting<br><br>

![ACI](./assets/2-40.png)<br><br>

![ACI](./assets/2-41.png)<br><br>

Re-run the test and check the results<br><br>

![ACI](./assets/2-42.png)<br><br>


## Task 4
Allow traffic from outside 198.18.2.x to inside 198.18.6.x<br>
(by default both PCâ€™S cannot ping/connect to the 198.18.6.x network)<br><br>

Check Kali PC IP/Mask/Gateway/routing and ping test<br><br>

![ACI](./assets/2-43.png)<br><br>

![ACI](./assets/2-44.png)<br><br>

Check Windows PC IP/Mask/Gateway/routing and ping test<br><br>

![ACI](./assets/2-45.png)<br><br>

![ACI](./assets/2-46.png)<br><br>

Configure ACP and NAT rules to allow those traffic<br><br>

![ACI](./assets/2-47.png)<br><br>

![ACI](./assets/2-48.png)<br><br>

Then re-run tests again<br><br>

![ACI](./assets/2-49.png)<br><br>

![ACI](./assets/2-50.png)<br><br>


## Task 5
IPS Policy creating and testing<br><br>
In this scenario will create IPS rule to block icmp traffic<br><br>
To test the policy, please generate traffic between inside and outside interfaces<br><br>

![ACI](./assets/2-51.png)<br><br>

![ACI](./assets/2-52.png)<br><br>

![ACI](./assets/2-53.png)<br><br>

![ACI](./assets/2-54.png)<br><br>

![ACI](./assets/2-55.png)<br><br>

![ACI](./assets/2-56.png)<br><br>

![ACI](./assets/2-57.png)<br><br>

![ACI](./assets/2-58.png)<br><br>



Apply IPS policy to ACP rule<br><br>

![ACI](./assets/2-59.png)<br><br>

Deploy the changes<br><br>

Check the events (under connection events or unified events)<br><br>

![ACI](./assets/2-60.png)<br><br>

![ACI](./assets/2-61.png)<br><br>

![ACI](./assets/2-62.png)<br><br>


## Task 6
Your task is to configure a site-to-site VPN between the two sites (details below). Finally, to verify the success of this task, you should be able to establish connectivity (ping) between 198.18.5.0/24 and 198.18.6.0/24. If not, please start troubleshooting.
<br>

FMC https://198.18.1.2
username:admin
PW: Cisco@123
<br>
Windows 11:
admin / C1sco12345
<br>
Kali Linux:
kali / C1sco12345
<br>

Site to Site VPN Diagram and details
<br>
```nginx
1. OUTSIDE
   Firepower FTD = 198.18.1.4
   Encrypted traffic = 198.18.5.0/24

2. ACME
   Firepower FTD = 198.18.2.4
   Encrypted traffic = 198.18.6.0/24
```
<br>

![ACI](./assets/v42.png)
<br><br>

These are all the test tasks
```nginx
1. ping from 198.18.6.6 to 198.18.5.6
2. ping from 198.18.5.6 to 198.18.6.6
```
<br><br>

Create site to site VPN in FMC 198.18.2.2<br><br>

![ACI](./assets/v6.png)<br>

![ACI](./assets/v7.png)<br>

![ACI](./assets/v8.png)<br>

![ACI](./assets/v9.png)<br>

![ACI](./assets/v10.png)<br>

![ACI](./assets/v11.png)<br>

![ACI](./assets/v12.png)<br>

![ACI](./assets/v13.png)<br>

![ACI](./assets/v14.png)<br>
<br><br>

Site to Site VPN Unknow Status<br>
![ACI](./assets/v1.png)
<br><br>

ACP Rule (allow all)<br>

![ACI](./assets/v2.png)
<br><br>

NAT Rules<br>
![ACI](./assets/v3.png)
<br><br>

Site to Site VPN Active Status<br>
(Please note: VPN shows as active once you configure the remote site only)<br>

![ACI](./assets/v4.png)
<br>
![ACI](./assets/v5.png)
<br><br>

Testting from Kali PC
![ACI](./assets/v15.png)
<br><br>

Check STS VPN status through FTD CLI (198.18.2.3)
![ACI](./assets/v16.png)<br>

![ACI](./assets/v17.png)<br>

![ACI](./assets/v18.png)<br>
<br><br>

Check STS VPN status through FMC
![ACI](./assets/v19.png)
<br><br>



Create site to site VPN in FMC 198.18.1.2<br><br>

Site to Site VPN Unknow Status<br>

![ACI](./assets/v20.png)<br>

![ACI](./assets/v21.png)<br>

![ACI](./assets/v22.png)<br>

![ACI](./assets/v23.png)<br>

![ACI](./assets/v24.png)<br>
<br><br>

Testting from Kali PC
![ACI](./assets/v25.png)<br>
<br><br>

Check STS VPN status through FTD CLI (198.18.1.3)
![ACI](./assets/v26.png)<br>

![ACI](./assets/v27.png)<br>

![ACI](./assets/v28.png)<br>
<br><br>


Event View

![ACI](./assets/v29.png)<br>

![ACI](./assets/v30.png)
<br><br>

Check STS VPN status through FMC
![ACI](./assets/v31.png)
<br><br>


## Task 7

- This task tests the Secure Firewall file policy. 
- Kali PC (198.18.6.6) trying to download block file from web server (198.18.2.11).
- (For testing purpose, please host the web server on kali PC 198.18.2.11 using the Python web module shown bottom of this page. also make sure to download test jpg file from google to the 198.18.2.11 folder)
<br>

![ACI](./assets/filepolicy.png)<br>

- Creating File Policy in Secure Firewall<br>

![ACI](./assets/v35.png)<br>

![ACI](./assets/v36.png)<br>

![ACI](./assets/v37.png)<br>


- Hosting web server in Kali PC<br>
![ACI](./assets/v38.png)<br>

- Client trying to download the file<br>
![ACI](./assets/v39.png)<br>

- Web server logs<br>
![ACI](./assets/v40.png)<br>

- Secure Firewall logs<br>
![ACI](./assets/v41.png)<br>


## Kali linux tcpdump

Specific traffic from to

![ACI](./assets/v32.png)
<br><br>

any traffic between hosts
![ACI](./assets/v33.png)
<br><br>


## Host web server in kali linux

![ACI](./assets/v34.png)<br>

