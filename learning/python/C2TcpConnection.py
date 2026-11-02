"""
C2TcpConnection.py - Context-managed TCP socket connection for C2 communication.
Provides robust connection lifecycle management, command delivery, and response retrieval.
"""

import socket


class C2TcpConnection:
    def __init__(self, address: str, port: int, text: str = ""):
        # Create standard IPv4 / TCP socket
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.address = address
        self.port = port
        self.text = text

    def __enter__(self):
        # Establish connection to target address and port
        self.sock.connect((self.address, self.port))
        if self.text:
            self.sock.send(self.text.encode())
        return self

    def receive_response(self, buffer_size: int = 1024) -> str:
        data_bytes = self.sock.recv(buffer_size)
        if data_bytes:
            return data_bytes.decode()
        return "No data received or connection terminated by remote peer."

    def send_command(self, command: str) -> None:
        self.sock.send(command.encode())

    def __exit__(self, exc_type, exc_value, traceback):
        # Cleanly terminate the connection when exiting context
        self.sock.close()


if __name__ == '__main__':
    # Standalone verification example
    print("C2TcpConnection client initialized.")
