# Build nginx image
```bash
docker build -t nginx-with-my-ip -f nginx.Dockerfile .
docker run --name=nginx -d -p 80:80 nginx-with-my-ip
```