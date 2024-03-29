<pre><code>
# Follow instruction from following link to setup ingress controller
https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/

# For setting up intress resources follow following link
https://www.youtube.com/watch?v=chwofyGr80c

# Must need to give a try with following jwt-keycloak
install kong-plugin-jwt-keycloak
https://github.com/gbbirkisson/kong-plugin-jwt-keycloak
</code></pre>

# Kong ip restriction when it behine proxy
Source: https://tech.aufomm.com/how-to-use-ip-restriction-plugin/

Also take a look: https://joshuajordancallis.medium.com/kong-ip-restriction-plugin-within-kubernetes-1ab8386f7ca3

https://docs.konghq.com/kubernetes-ingress-controller/latest/guides/preserve-client-ip/

https://docs.konghq.com/gateway/latest/reference/configuration/#real_ip_header
```
Extended information
There is one settings users need to know about is how to get the correct client_ip when you are running Kong behind a proxy or load balancer. For more information about getting client ip behind proxy, please refer to this serverfault answer.

When Kong is behind the proxy or LB, it sees the traffic from IP_address of the proxy or LB instead of the correct client ip. To solve this issue, there are 3 kong variables you need to use.

TRUSTED_IPS=proxy_ip, load_balancer_ip
REAL_IP_HEADER=X-Forwarded-For
REAL_IP_RECURSIVE=on
```

#Trusted IP and set Other hreader as ClientIP example
```
KONG_ADMIN_ACCESS_LOG:        /dev/stdout
      KONG_ADMIN_ERROR_LOG:         /dev/stderr
      KONG_ADMIN_GUI_ACCESS_LOG:    /dev/stdout
      KONG_ADMIN_GUI_ERROR_LOG:     /dev/stderr
      KONG_ADMIN_LISTEN:            127.0.0.1:8444 http2 ssl
      KONG_CLUSTER_LISTEN:          off
      KONG_DATABASE:                postgres
      KONG_KIC:                     on
      KONG_LUA_PACKAGE_PATH:        /opt/?.lua;/opt/?/init.lua;;
      KONG_NGINX_WORKER_PROCESSES:  2
      KONG_PG_DATABASE:             kong
      KONG_PG_HOST:                 kong-database.devpanel.svc.cluster.local
      KONG_PG_PASSWORD:             xxxx
      KONG_PG_USER:                 kong
      KONG_PLUGINS:                 bundled
      KONG_PORTAL_API_ACCESS_LOG:   /dev/stdout
      KONG_PORTAL_API_ERROR_LOG:    /dev/stderr
      KONG_PORT_MAPS:               80:8000, 443:8443
      KONG_PREFIX:                  /kong_prefix/
      KONG_PROXY_ACCESS_LOG:        /dev/stdout
      KONG_PROXY_ERROR_LOG:         /dev/stderr
      KONG_PROXY_LISTEN:            0.0.0.0:8000 proxy_protocol, 0.0.0.0:8443 ssl proxy_protocol
      KONG_REAL_IP_HEADER:          proxy_protocol  <======================= customization of ClientIP
      KONG_STATUS_LISTEN:           0.0.0.0:8100
      KONG_STREAM_LISTEN:           off
      KONG_TRUSTED_IPS:             0.0.0.0/0,::/0 <========================= Allow IPs
    Mounts:
```
# For docker
```
Now when we run below command from our host or a different VM

1
curl https://test.demofor.fun/echo -s | jq -r '.request.headers["x-forwarded-for"]'
We should get something like 122.221.122.221, 108.162.249.37, 172.18.0.2.

Understand IPs from x-forwarded-for headers
Let’s take a look at these IP addresses

122.221.122.221: This is my VM’s IP address which is the client IP I would like Kong to get and restrict on.
172.18.0.2: This is a local IP address. If we check our container address, this is the IP of traefik container.
108.162.249.37: This is a public IP address belongs to Cloudflare.
Now we know 122.221.122.221 is the IP I want Kong to get, we need to put 172.18.0.2 and 108.162.249.37 as trusted ips.

Deploy Kong with trusted_ips
Let’s stop and re-create our Kong container with below commands.

#Sources https://tech.aufomm.com/how-to-get-real-client-ip-when-kong-is-behind-cdn-and-loadbalancer/
docker run --detach --rm \
  --name kong \
  --network traefik \
  -p "8001:8001" \
  -e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
  -e "KONG_PROXY_LISTEN=0.0.0.0:8000" \
  -e "KONG_DATABASE=off" \
  -e "KONG_TRUSTED_IPS=108.162.249.37, 172.18.0.2" \
  -e "KONG_REAL_IP_HEADER=X-Forwarded-For" \
  -e "KONG_REAL_IP_RECURSIVE=on" \
  kong:3.0-ubuntu
```
