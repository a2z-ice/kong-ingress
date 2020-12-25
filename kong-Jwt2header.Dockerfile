FROM kong:latest
LABEL description="Centos 7 + Kong 2.0.4 + kong-oidc plugin"

USER root
#ENV KONG_PLUGINS=oidc,cors,prometheus,jwt,basic-auth,hmac-auth,key-auth,ldap-auth,oauth2,session,bot-detection
ENV KONG_PLUGINS=bundled,oidc,kong-jwt2header

RUN apk add --no-cache git && luarocks install kong-oidc && luarocks install kong-jwt2header

#----------------build----------------and run
