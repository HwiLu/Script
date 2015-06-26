#!/bin/bash

test -d /root/.ssh || mkdir -p /root/.ssh 

if [ $? = '0' ];then 
	chown root.root /root
	chmod 700 /root/.ssh
fi

wget http://yum.kjtprod.com/tools/authorized_keys -O /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
