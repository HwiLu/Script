#!/bin/bash

### add user ###
groupadd zabbix
useradd -g zabbix -s /sbin/nologin zabbix

### install ###
cd /usr/local/
wget http://yum.kjtprod.com/tools/zabbix_linux_agentd.tar.gz
tar -zxvf zabbix_linux_agentd.tar.gz
chown zabbix.zabbix -R /usr/local/zabbix_agentd/
cp /usr/local/zabbix_agentd/zabbix_agent /etc/init.d/zabbix_agent
/etc/init.d/zabbix_agent start
echo "/etc/init.d/zabbix_agent start" >> /etc/rc.local
