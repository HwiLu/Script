#!/bin/bash

#Local_IP=`ifconfig eth0|grep 'inet addr'|awk -F'r:|  B' '{print $2}'`

### install packages ###
yum groupinstall "Development Libraries" "Development Tools" -y
yum install ntp sysstat pcre pcre-devel net-snmp ncurses-devel libxml2-devel lrzsz openssl-devel dstat glibc.i686 wget vim mlocate telnet bzip2* tree  gcc dmidecode pciutils redhat-lsb -y

### init ssh ###
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config 
/etc/init.d/sshd restart

### set ntp ###
ntpdate 202.120.2.101
echo "0 * * * * root ntpdate 202.120.2.101 > /dev/null 2>&1" >> /etc/crontab

### init service ###
open_list=`chkconfig --list|grep '3:on'|awk '{print $1}'`
for srv1 in $open_list
do
	chkconfig $srv1 off
	/etc/init.d/$srv1 stop
done

srv_list="crond haldaemon network rsyslog sshd"
for srv2 in $srv_list
do
	chkconfig $srv2 on
	/etc/init.d/$srv2 start
done

### init sysctl ###
modprobe nf_conntrack
echo "modprobe nf_conntrack">> /etc/rc.local
echo "net.ipv4.tcp_syncookies = 1           
net.ipv4.tcp_tw_reuse = 1             
net.ipv4.tcp_tw_recycle = 2            
net.ipv4.ip_local_port_range = 4096 65000  
net.ipv4.tcp_max_tw_buckets = 5000     
net.ipv4.tcp_max_syn_backlog = 4096    
net.core.netdev_max_backlog =  10240  
net.core.somaxconn = 2048              
net.core.wmem_default = 8388608        
net.core.rmem_default = 8388608        
net.core.rmem_max = 16777216           
net.core.wmem_max = 16777216           
net.ipv4.tcp_synack_retries = 2        
net.ipv4.tcp_syn_retries = 2           
net.ipv4.tcp_tw_recycle = 1            
net.ipv4.tcp_max_orphans = 3276800     
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_retrans_collapse = 0
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

### set ulimit ###
echo '* - nofile 65535' >> /etc/security/limits.conf
echo 'ulimit -HSn 65535' >> /etc/profile
if [ -f /etc/security/limits.d/90-nproc.conf ];then
        sed -i.bak "s/^\*/#\*/"p  /etc/security/limits.d/90-nproc.conf
fi

### disable control-alt-delete ###
sed -i.bak '/shutdown/s/^/#/g' /etc/init/control-alt-delete.conf

### del user&group ###
for user in adm lp sync shutdown halt uucp operator games gopher 
do
	userdel $user
done

for group in adm lp dip 
do
	groupdel $group
done
