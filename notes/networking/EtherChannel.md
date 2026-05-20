If you connect two swtiches together with multiple links, all except one will be disabled by STP.
If all interfaces were forwarding, Layer 2 loops would form between swtiches leading to broadcast storms
Other links will be unused unless the active link fails.

EtherChannel groups multiple interfaces together to act as a single interface.
STP will treat this group as a single interface. 
EtherChannel load balances based on 'flows' (communication between two nodes in the network)

Frames in the same flow will be forwarded by the same physical interface. (if not some frames may arrive at the destination out of order, causing problems)

Inputs to change interface selection calculation:
- Source / Destination MAC
- Source AND Destination MAC
- Source / Destination IP
- Source AND Destination IP
	`show etherchannel load-balance`
	`port-channel load-balance "input"`
		`src-dst-ip / src-dst mac`

## EtherChannel Configuration
Three methods on Cisco switches:
### PAgP (Port Aggregation Protocol)
Proprietary  protocol. Dynamically negotiates the creation/maintainance of the EtherChannel (like DTP for trunks)
`channel-group 1 mode auto/desirable`
### LACP (Link Aggregation Control Protocol)
IEEE 802.3ad, same as PAgP
`channel-group 1 mode active/passive`
### Static EtherChannel
No protocol used to form an EtherChannel configuration
Interfaces are statically configured to form a EtherChannel
`channel-group 1 mode on`
Up to 8 interfaces can be formed into a single EtherChannel (LACP allows up to 16, but only 8 will be active, the other 8 will be in standby mode)

Member interfaces must have matching configurations:
- Same duplex
- Same speed
- Same switchport mode
- Same allowded VLANs

`show etherchannel summary`