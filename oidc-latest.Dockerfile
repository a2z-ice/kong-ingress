FROM kong:latest
LABEL description="Centos 7 + Kong 2.0.4 + kong-oidc plugin"

USER root
#ENV KONG_PLUGINS=oidc,cors,prometheus,jwt,basic-auth,hmac-auth,key-auth,ldap-auth,oauth2,session,bot-detection
ENV KONG_PLUGINS=bundled,oidc
#acl,basic-auth,file-log,key-auth,oidc,rate-limiting,response-transformer,udp-log,acme,bot-detection,hmac-auth,ldap-auth,post-function,request-size-limiting,session,zipkin,aws-lambda,correlation-id,http-log,pre-function,request-termination,statsd,azure-functions,cors,ip-restriction,loggly,prometheus,request-transformer,syslog,datadog,jwt,oauth2,proxy-cache,response-ratelimiting,tcp-log



RUN apk add --no-cache git && luarocks install kong-oidc && luarocks install kong-jwt2header
