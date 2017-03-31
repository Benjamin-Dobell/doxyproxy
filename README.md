# doxyproxy 
## Dynamic reverse proxy for Docker containers

Hosting multiple sites on a single server is nothing new - it's as old as
the web itself. nginx already supports this use case, but an `nginx.conf`
file needs to be updated and nginx itself reloaded whenever a config change
(e.g. backend server IP address, listening domain name) happens. 

This is problematic when using Docker containers as backend servers because 
typically Docker containers have dynamically assigned IP addresses. `doxyproxy`
solves this by looking up backend server containers' IP addresses _on-demand_
inside the nginx process itself. This is achieved using OpenResty. 

## Usage

### Example

```
docker run -d \
  --label com.glassechidna.doxyproxy.HttpHost=example.com \
  --label com.glassechidna.doxyproxy.HttpPort=80 \
  nginx

docker run -d \
  --label com.glassechidna.doxyproxy.HttpHost=example2.com \
  --label com.glassechidna.doxyproxy.HttpPort=80 \
  nginx

docker run -d --net=host -p 8080:8080 glassechidna/doxyproxy
curl -H 'Host: example.com' http://localhost:8080/ # forwarded to the first container
curl -H 'Host: example2.com' http://localhost:8080/ # forwarded to the second container
```

`doxyproxy` determines the container to forward traffic to by looking for a
container with a matching `com.glassechidna.doxyproxy.HttpHost` label. `doxyproxy`
then uses the `com.glassechidna.doxyproxy.HttpPort` label to know which port
the web traffic should be forwarded to in that container.

**Note**: In the above example the `--net=host` networking mode command is not
strictly necessary as the three containers are launched into the same default
Docker bridge network and hence the `doxyproxy` container has connectivity to
the other two. Where the host network mode _does_ become necessary is when you
wish to forward traffic to containers in _other_ Docker networks.

## Credit

This project is originally based on the great work done by [`sourcelair/ceryx`][ceryx].

[ceryx]: https://github.com/sourcelair/ceryx
