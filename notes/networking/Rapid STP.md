RSTP is not a timer-based ST algorithm like .1D. Therefore, RSTP offers an improvement over the 30 seconds or more that 802.1D takes to move a link to forwarding. The heart of the protocol is a new bridge-bridge hadshake mechanism, which allows ports to move directly to forwarding.

All switches send RSTP BPDUs
## Similarities between STP and RSTP
RSTP serves the same pupose as STP, blocking specific ports to prevent L2 loops.
RSTP elects a root bridge with the same rules as STP
RSTP elects root ports with the same rules as STP.
RSTP elects designated ports with the same rules as STP.


![[Pasted image 20260504191252.png]]

## Port states
- **Discarding**
- **Learning**
- **Forwarding**
## Port roles
**Root port** and **designated port** remains unchanged in RSTP.
**Undesignated port** state is divided in:
- Alternate port (discarding port that receives a superior BPDU from another switch)
	- Same as blocking ports in classic STP
	- Functions as a backup to the root port.
	- If the root port fails, the switch can immediately move its best alternate port to forwarding.
-  Backup port (discarding port that receives a superior BPDU from another interface on the same switch)
	- Only happens when two interfaces are connected to the same collision domain (via a hub)
	- Hubs are not used in modern networks, so you will porobably not encounter an RSTP backup port
	- Function as a buckup for a designated port.


## Link Types
- **Edge**: a port is connected to an end host. Moves directly to forwarding, without negotiation. (Portfast)
	- `spanning-tree portfast`
- ** **: direct connection between two switches
	- `spanning-tree link-type point-to-point`
- **Shared**: connection to a hub. Must operate in half-duplex mode.
	- `spanning-tree link-type shared`