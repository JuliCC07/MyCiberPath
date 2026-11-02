"""
lab_network_topology.py - Virtual Lab Topology & OOP Inheritance Model
Simulates network devices (Switches, Routers, Firewalls) and demonstrates
object introspection, MRO resolution, and attribute encapsulation.
"""


class Device:
    """Base class for all network lab devices."""
    active_devices = []

    def __init__(self, name: str, ip: str, mac: str):
        self.name = name
        self.ip = ip
        self.mac = mac
        Device.active_devices.append(self)

    def __str__(self) -> str:
        return f"[Device] {self.name} - IP: {self.ip}"

    def __getattribute__(self, name: str):
        # Attribute interception demonstration
        if name in ['__class__', '__mro__', '__subclasses__', '__dict__']:
            raise AttributeError(f"Access blocked for attribute: {name}")
        return super().__getattribute__(name)


class Switch(Device):
    """Layer 2 network switch managing port-to-MAC associations."""

    def __init__(self, name: str, ip: str, mac: str):
        super().__init__(name, ip, mac)
        self.ports = {}

    def connect_device(self, port: int, target_mac: str) -> None:
        self.ports[port] = target_mac


class Router(Device):
    """Layer 3 router managing network routing tables."""

    def __init__(self, name: str, ip: str, mac: str):
        super().__init__(name, ip, mac)
        self.routing_table = {}

    def add_route(self, dest_network: str, gateway: str) -> None:
        self.routing_table[dest_network] = gateway


class IntelligentDevice:
    """Interface mixin for managed and intelligent network appliances."""
    pass


class CiscoFirewall(Router, IntelligentDevice):
    """Stateful firewall inheriting routing capabilities and intelligence mixin."""
    pass


if __name__ == '__main__':
    # Demonstrate object encapsulation and attribute blocking
    lab_router = Router("R1", "192.168.1.1", "AA:BB:CC:DD:EE:FF")
    print(f"Instantiated: {lab_router}")

    # Inspect inheritance order via class MRO
    print("CiscoFirewall MRO:", CiscoFirewall.__mro__)

    try:
        print(lab_router.__dict__)
    except AttributeError as err:
        print(f"Expected security restriction: {err}")
