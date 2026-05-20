---
categories:
  - "[[Ciber]]"
tags:
  - networking
  - ccna
  - stp
  - commands
created: 2026-03-12
---
Lab used commands:
show spanning-tree
show spanning-tree detail
show spanning-tree summary


## [[2026-05-04]]
### IEEE Versions:
#### 802.1D
Original STP
All VLANs share one STP instance
Cannot load balance
#### 802.1w
Much faster at converging/adapting to network changes than 802.1D
All VLANs share one STP instance
Cannot load balance
#### 802.1s
Uses modified .1w mechanics.
Can group multiple VLANs into different instances to perform load balancing

### Cisco Versions
#### PVST+
Cisco's upgrade to 802.1D
Each VLAN has its own STP instance
Can load balance by blocking different ports in each VLAN
#### Rapid PVST+
Upgrade to 802.1w
Each VLAN has its won STP instance
Can load balance by blocking different ports in each VLAN