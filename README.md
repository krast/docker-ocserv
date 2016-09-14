# docker-ocserv


docker run --name ocserv \
    --privileged \
    -d \
    --restart=always \
    -p 85:443 \
    -p 85:443/udp \
    -v /root/certs/server-key.pem:/etc/ocserv/certs/server-key.pem:ro \
    -v /root/certs/server-cert.pem:/etc/ocserv/certs/server-cert.pem:ro \
    krast0/ocserv
