echo "alias ll='ls -al'" >> /etc/profile
source /etc/profile
cat << EOF > /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl -p
sed -i "s/#http/http/g" /etc/apk/repositories
apk update && apk upgrade -a
apk add docker docker-cli-compose
rc-update add docker && service docker start
apk add clamav && rc-update add clamd
/etc/init.d/docker stop
umount /var/lib/docker
rm -rf /var/lib/docker
ln -s /data/.docker_root /var/lib/docker
reboot

docker network create -d macvlan --subnet=198.19.201.0/24 --gateway=198.19.201.254 -o parent=eth0 macvlan-eth0
cat << EOF > /etc/local.d/local.start
ip link add macvlan-eth0 link eth0 type macvlan mode bridge
ip link set macvlan-eth0 up
ip addr add 198.19.201.253/24 dev macvlan-eth0
ip route add 198.19.201.252/32 via 198.19.201.253
ip route add 198.19.201.251/32 via 198.19.201.253
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
modprobe tun
EOF
chmod +x /etc/local.d/local.start
rc-update add local && rc-service local start




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


