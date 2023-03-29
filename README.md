# Playing with Python sockets and containers

## Running th server locally

> Running the server locally (host and port are optional). Press ctrl+C to close

```sh
Usage: ipc_multiconn_server.py <host> <port
```

```sh
python ipc_multiconn_server.py
```

>output

```text
Listening on ('0.0.0.0', 8080)
```

```sh
python ipc_multiconn_server.py 127.0.0.1 9999
```

>output

```text
Listening on ('127.0.0.1', 9999)
```

## Running the server from a container

### Docker Build

> build the ipc-server image

```sh
 docker build -t ipc-server:1.0 .
```

### Docker Run

> run the server container explicitly publishing <host port><contsiner port>

```sh
docker run --name ipc-server -d -p 8080:8080 ipc-server:1.0
```

```sh
netstat -ant | grep LISTEN | grep 8080
```

>output

```text
tcp46      0      0  *.8080                 *.*                    LISTEN
```

> Using the -P (upper case) flag at runtime lets you publish all exposed ports to random ports on the host interfaces.<br>It’s short for –publish-all.

```sh
docker run --name ipc-server -d -P ipc-server:1.0
```

```sh
docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}" -a | grep "ipc-server"
```

>output

```text
e0760de2fead   ipc-server   0.0.0.0:32769->8080/tcp, 0.0.0.0:32769->8080/ud
```

> run the server specifying custom host and port using environment variables

```sh
docker run --name ipc-server --env HOST=0.0.0.0 --env PORT=9999 -d -p 9090:9999 ipc-server:1.0
```

```sh
netstat -ant | grep LISTEN | grep 9999
```

>output

```text
tcp46      0      0  *.9999                 *.*                    LISTEN
```

> delete the container

```sh
docker container rm ipc-server --force
```

>output

```text
ipc-server
```

## Running the client

```sh
Usage: ipc_multiconn_client.py <host> <port> <num_connections>
```

```sh
python ipc_multiconn_client.py 127.0.0.1 8080 2
```

>output

```text
Starting connection 1 to ('127.0.0.1', 8080)
Starting connection 2 to ('127.0.0.1', 8080)
Sending b'Message 1 from client.' to connection 1
Sending b'Message 1 from client.' to connection 2
Sending b'Message 2 from client.' to connection 1
Sending b'Message 2 from client.' to connection 2
Received b'Message 1 from client.Message 2 from client.' from connection 1
Closing connection 1
Received b'Message 1 from client.Message 2 from client.' from connection 2
Closing connection 2
```

## Misc

> install debugging tools in ubuntu containers and testing out host.docker.internal

```sh
docker run \
--workdir /root \
--name ubuntu \
--network=host \
--interactive \
--tty \
--rm \
--volume "$(pwd)"/ipc_multiconn_server.py:/root/ipc_multiconn_server.py \
--volume "$(pwd)"/ipc_multiconn_client.py:/root/ipc_multiconn_client.py \
ubuntu /bin/bash
```

```sh
apt-get update && \
apt-get install curl dnsutils iputils-ping python3.11 vim iproute2 net-tools -y && \
alias python=python3.11
```

```sh
nslookup host.docker.internal && \
ping -c 3 host.docker.internal
```

```sh
python ipc_multiconn_server.py &
# and press enter to get the prompt back
```

```sh
netstat -ant | grep LISTEN | grep 8080
```

```sh
python ipc_multiconn_client.py 0.0.0.0 8080 2
```

> Now open a new terminal window and try it from outside the container<br>
this fill **fail** and there seems to be an open issue about it [here](https://github.com/docker/for-mac/issues/2716) 

```sh
python ipc_multiconn_client.py 0.0.0.0 8080 2
```

>output

```text
Starting connection 1 to ('0.0.0.0', 8080)
Starting connection 2 to ('0.0.0.0', 8080)
Sending b'Message 1 from client.' to connection 1
Traceback (most recent call last):
  File "/Users/ssscse/Documents/coding/python/networking/sockets/ipc_multiconn_client.py", line 64, in <module>
    service_connection(key, mask)
  File "/Users/ssscse/Documents/coding/python/networking/sockets/ipc_multiconn_client.py", line 48, in service_connection
    sent = sock.send(data.outb)  # Should be ready to write
BrokenPipeError: [Errno 32] Broken pipe
```

> netstat also shows no open port 8080

```sh
netstat -antu | grep LISTEN | grep 8080
```

>output

```text

```
