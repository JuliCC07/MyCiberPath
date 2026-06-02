class Device:
    active_devices = []

    def __init__(self, name, ip, mac):
        self.name = name
        self.ip = ip
        self.mac = mac
        Device.active_devices.append(self)

    def __str__(self):
        return f"[Device] {self.name} - IP: {self.ip}"
    
    def __getattribute__(self, name):
        if name in ['__class__', '__mro__', '__subclasses__', '__dict__']:
            raise AttributeError(f"Acceso bloqueado al atributo: {name}")
        return super().__getattribute__(name)


class Switch(Device):
    def __init__(self, name, ip, mac):
        super().__init__(name, ip, mac)
        self.ports = {}
        pass

    def connect_device(self, port, target_mac):
        self.ports[port] = target_mac
        pass


class Router(Device):
    def __init__(self, name, ip, mac):
        super().__init__(name, ip, mac)
        self.routing_table = []

    def add_route(self, dest_network, gateway):
        self.routing_table = {"network": dest_network, "gateway": gateway}
        pass


mi_router = Router("R1", "192.168.1.1", "AA:BB:CC:DD:EE:FF")

print(mi_router.__dict__)

mi_router.__dict__["ip"] = "10.0.0.1"

print(mi_router)


class IntelligentDevice:
    pass


class FirewallCisco(Router, IntelligentDevice):
    pass


print(FirewallCisco.__mro__)
