# Build nginx image
```bash
docker build -t nginx-with-my-ip -f nginx.Dockerfile .
docker run --name=nginx -d -p 80:80 --network host --name nginx nginx-with-my-ip

# Note [If you do not set --network host then the x-forward-for or x-real-ip header will set lookback up which is 172.17.0.1]

# However the latest docker do not support to publish ip with host mode so better us nginx install in you pc for the time being until find the solution

```