#!/bin/bash

docker exec -i plinode /bin/bash -c ". ~/.profile && pm2 start /pluginAdm/startNode.sh"
cd /opt/docker/goplugin/plugin-deployment
docker exec --env-file ei.env -i plinode /bin/bash -c ". ~/.profile && pm2 start /pluginAdm/startEI.sh"

NOW=$( date '+%F_%H:%M:%S' )

echo "Node started on" $NOW "after reboot!" >> /root/plireboot.log
