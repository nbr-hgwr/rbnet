# Rbnet

## Usage
### Bridge
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