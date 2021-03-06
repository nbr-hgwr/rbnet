# Rbnet

## Usage
### Vagrant
```
vagrant up

vagrant ssh node*
  sudo yum update -y
  exit

vagrant reload node*

vagrant ssh node1
  sudo su -
  cd /vagrant
  bundle install
  bundle exec exe/rbnet router -i "eth1 eth2"

# node2
sudo ip route delete default
sudo ip route add default via 192.168.10.2 dev eth1

# node3
sudo ip route delete default
sudo ip route add default via 192.168.20.2 dev eth1

# node5
sudo ip route delete default
sudo ip route add default via 192.168.40.2 dev eth1
```

### Docker
```
cd Docker

docker-compose build
docker-compose up -d

docker exec -it docker_rbnet_node1_1 /bin/sh
  source /etc/profile.d/rbenv.sh
  cd rbnet/
  bundle install
  bundle exec exe/rbnet bridge -i "eth0 eth1"

```