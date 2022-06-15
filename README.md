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
```
Extended information
There is one settings users need to know about is how to get the correct client_ip when you are running Kong behind a proxy or load balancer. For more information about getting client ip behind proxy, please refer to this serverfault answer.

When Kong is behind the proxy or LB, it sees the traffic from IP_address of the proxy or LB instead of the correct client ip. To solve this issue, there are 3 kong variables you need to use.

TRUSTED_IPS=proxy_ip, load_balancer_ip
REAL_IP_HEADER=X-Forwarded-For
REAL_IP_RECURSIVE=on
```
