# Create kong network
docker network create -d bridge  kong-net

# create container for posgres database
docker run -d --name kong-database --restart=always --network=kong-net -p 5432:5432 -e "POSTGRES_USER=kong" -e "POSTGRES_DB=kong" -e "POSTGRES_HOST_AUTH_METHOD=trust" postgres:11-alpine

# A docker image has been reated and pushed with assaduzzaman/kong-oidc in dockerhub
docker build -t kong-oidc -f oidc-latest.Dockerfile

# Create kong table in kong database. Here we can use assaduzzaman/kong-oidc instead of kong-oidc:latest because I have already created kong image in my docker registry
docker run --rm --network=kong-net  -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" kong-oidc:latest kong migrations bootstrap

# Create kong container. Alternatively assaduzzaman/kong-oidc instead of kong-oidc:latest
docker run -d --name kong --network=kong-net --restart always \
-e "KONG_DATABASE=postgres" \
-e "KONG_PG_HOST=kong-database" \
-e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
-p 80:8000 -p 443:8443 -p 8001:8001 -p 8444:8444 \
 kong-oidc:latest

# Create konga container a admin palne for kong
docker run -d -p 1337:1337 --network kong-net --name konga --restart=always -e "NODE_ENV=development" -e "TOKEN_SECRET=iu7YDcPLiZkozQXzZ9kka3Ee1Vid5ZgQ" -e "DB_ADAPTER=postgres" -e "DB_URI=postgresql://kong@kong-database:5432/konga_db" pantsel/konga:latest


# create service
 curl -s -X POST http://localhost:8001/services \
    -d name=mock-service \
    -d url=http://mockbin.org/request # upstream url
 
 Response: {"host":"mockbin.org","id":"662623c2-a105-41ff-995e-b0a1fba898b5","protocol":"http","read_timeout":60000,"tls_verify_depth":null,"port":80,"updated_at":1595667193,"ca_certificates":null,"created_at":1595667193,"connect_timeout":60000,"write_timeout":60000,"name":"mock-service","retries":5,"path":"\/request","tls_verify":null,"tags":null,"client_certificate":null}   

# add route for service created from above where service is "662623c2-a105-41ff-995e-b0a1fba898b5" is taken from above request
curl -s -X POST http://localhost:8001/routes \
    -d service.id=662623c2-a105-41ff-995e-b0a1fba898b5 \
    -d paths[]=/mock

Response: {"id":"c0a9b9ac-7f2e-418d-b471-79159b0e4304","path_handling":"v0","paths":["\/mock"],"destinations":null,"headers":null,"protocols":["http","https"],"created_at":1595667423,"snis":null,"service":{"id":"662623c2-a105-41ff-995e-b0a1fba898b5"},"name":null,"strip_path":true,"preserve_host":false,"regex_priority":0,"updated_at":1595667423,"sources":null,"methods":null,"https_redirect_status_code":426,"hosts":null,"tags":null}

#Verify everything working fine here port 80 is the kong proxy port which is being mapped in docker with 80:8080
curl -s http://localhost:80/mock

Response: {
  "startedDateTime": "2020-07-25T09:16:19.489Z",
  "clientIPAddress": "172.18.0.1",
  "method": "GET",
  "url": "http://localhost/request",
  "httpVersion": "HTTP/1.1",
  "cookies": {},
  "headers": {
      ....
  }

# Add/Configure plugin
CLIENT_SECRET=xxxxxxxxxx # kong client secret created on keycloak
BASE_URL=https://xxxxx.xxxx.xx # base url of keycloak 

# Please make sure you have set bearer_only=yes other wise it will not work and add introspection_endpoint it will use to validate token
curl -s -X POST http://localhost:8001/plugins \
  -d name=oidc \
  -d config.client_id=kong \
  -d config.client_secret=${CLIENT_SECRET} \
  -d config.discovery=${BASE_URL}/auth/realms/rand/.well-known/openid-configuration \
  -d config.introspection_endpoint=${BASE_URL}/auth/realms/rand/protocol/openid-connect/token/introspect \
  -d config.bearer_only=yes

 Response: {"created_at":1595672701,"id":"ea54ab06-71e6-45e7-8c8f-784f2d585e22","tags":null,"enabled":true,"protocols":["grpc","grpcs","http","https"],"name":"oidc","consumer":null,"service":null,"route":null,"config":{"response_type":"code","introspection_endpoint":null,"filters":null,"bearer_only":"no","ssl_verify":"no","session_secret":null,"introspection_endpoint_auth_method":null,"realm":"kong","redirect_after_logout_uri":"\/","scope":"openid","token_endpoint_auth_method":"client_secret_post","logout_path":"\/logout","client_id":"kong","client_secret":"xxxxx","discovery":"https:\/\/xxxxx.xxxx.xx\/auth\/realms\/rand\/.well-known\/openid-configuration","recovery_page_path":null,"redirect_uri_path":null}}

 # get plugin id:
 curl -s http://localhost:8001/plugins | jq -r .data[0].id 
PLUGIN_ID=$(curl -s http://localhost:8001/plugins | jq -r .data[0].id)

# update oidc plugin settings. Since when I ran it first time to create plugin a error occur
curl -X PATCH http://localhost:8001/plugins/${PLUGIN_ID} \
    -d config.introspection_endpoint=${BASE_URL}/auth/realms/rand/protocol/openid-connect/token/introspect \
    -d config.discovery=${BASE_URL}/auth/realms/rand/.well-known/openid-configuration


Response: {"created_at":1595672701,"id":"ea54ab06-71e6-45e7-8c8f-784f2d585e22","tags":null,"enabled":true,"protocols":["grpc","grpcs","http","https"],"name":"oidc","consumer":null,"service":null,"route":null,"config":{"response_type":"code","introspection_endpoint":"https:\/\/xxxxx.xxxx.xx\/auth\/realms\/master\/protocol\/openid-connect\/token\/introspect","filters":null,"bearer_only":"no","ssl_verify":"no","session_secret":null,"introspection_endpoint_auth_method":null,"realm":"kong","redirect_after_logout_uri":"\/","scope":"openid","token_endpoint_auth_method":"client_secret_post","logout_path":"\/logout","client_id":"kong","client_secret":"xxxxxxx","discovery":"https:\/\/xxxxx.xxxx.xx\/auth\/realms\/rand\/.well-known\/openid-configuration","recovery_page_path":null,"redirect_uri_path":null}}

ACCESS_TOKEN=$(curl -s ${BASE_RUL}/auth/realms/rand/protocol/openid-connect/token \
  -d grant_type=client_credentials \
  -d client_id=kong \
  -d client_secret=${CLIENT_SECRET} \
  | jq -r .access_token) 

curl -s -X POST ${BASE_URL}/auth/realms/rand/protocol/openid-connect/token/introspect \
  -d token=${ACCESS_TOKEN} \
  -d client_id=kong \
  -d client_secret=${CLIENT_SECRET}

curl -s $BASE_URL/auth/realms/rand/protocol/openid-connect/token \
  -d grant_type=client_credentials \
  -d client_id=kong \
  -d client_secret=${CLIENT_SECRET} \
  | jq -r .access_token  
  


