mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
modprobe tun
apk add networkmanager-openvpn openvpn-dev
cat << EOF > /data/zt1/docker-compose.yaml
services:
  zerotier:
    image: registry.cn-hangzhou.aliyuncs.com/cxlj/zerotier
    network_mode: host
    container_name: zt1-client
    restart: always
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    volumes:
      - ./zerotier-one:/var/lib/zerotier-one
    command:
      - 0063d09ecf6d211e
EOF

cd /data/zt1/ && docker-compose up -d