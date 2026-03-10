import socket
class C2TcpConnection():
    def __init__(self, address, port, text):
        # Creamos el socket IPv4 / TCP
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.address = address
        self.port = port
        self.text = text 
    
    def __enter__(self):
        # Iniciamos la conexión usando la tupla (IP, Puerto)
        self.sock.connect((self.address, self.port))
        # Enviar strings si es necesario
        self.sock.send(self.text.encode())
        return self
    
    def receive_response(self):
        data_bytes = self.sock.recv(1024)
        if data_bytes:
            return data_bytes.decode()
        else:
            return "No se recibieron datos o la conexión se cerró"
    
    def send_command(self, command):
        # self.command = command # Opcional porque no hemos consultado el comando en ningún lugar del código
        self.sock.send(command.encode())

    def __exit__(self, exc_type, exc_value, traceback):
        # Cerramos la conexión al salir del bloque "with"
        self.sock.close()

with C2TcpConnection(address="10.10.10.10", port=8001, text="p4ssw0rd") as conn:
    respuesta = conn.receive_response()
    conn.send_command("whoami")

print(respuesta)