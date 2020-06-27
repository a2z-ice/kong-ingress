docker run -d --name kong-database --restart=always --network=kong-net -p 5432:5432 -e "POSTGRES_USER=kong" -e "POSTGRES_DB=kong" -e "POSTGRES_HOST_AUTH_METHOD=trust" postgres:11-alpine
docker ps

docker run --rm --network=kong-net  -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" kong-oidc:latest kong migrations bootstrap

-e KONG_CUSTOM_PLUGINS

docker run -d --name kong --network=kong-net --restart always \
-e "KONG_DATABASE=postgres" \
-e "KONG_PG_HOST=kong-database" \
-e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
-e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
-e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
-e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
-e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
-e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
-p 80:8000 -p 443:8443 -p 8001:8001 -p 8444:8444 \
--ip 172.1.1.40 kong-oidc:latest
docker ps

docker run -d -p 1337:1337 --network kong-net --name konga --restart=always -e "NODE_ENV=development" -e "TOKEN_SECRET=iu7YDcPLiZkozQXzZ9kka3Ee1Vid5ZgQ" -e "DB_ADAPTER=postgres" -e "DB_URI=postgresql://kong@kong-database:5432/konga_db" pantsel/konga:latest
docker ps

http://192.168.0.101:8001

curl -X POST http://192.168.0.101:8001/plugins \
    --data "name=kong-jwt2header" \
    --data "config.strip_claims=false" \
    --data "config.token_required=true"


curl -X POST http://192.168.0.101:8001/services/mock-service/plugins \
    --data "name=kong-upstream-jwt"     
    
    
    http://192.168.0.101:8001/plugins/
