#!/bin/bash

### check dns ###
cat /etc/resolv.conf|grep '6.41'
if [ $? -ne '0' ]; then
	sed -i '1 i nameserver 10.10.6.41' /etc/resolv.conf
fi

### install salt-minion ###
curl -s http://10.10.3.14/shell/ali_mirrors.sh|sh
yum -y install salt-minion

### modify config ###
local_ip=`ifconfig eth0|grep 'inet addr:'|awk -F':' '{print $2}'|awk '{print $1}'`
echo "master: 192.168.1.122" >> /etc/salt/minion
echo "id: `hostname`_$local_ip" >> /etc/salt/minion

### start service ###
/etc/init.d/salt-minion start
