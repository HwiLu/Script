#!/bin/bash

check_system (){
SYSTEM_INFO=`head -n 1 /etc/issue`
case "${SYSTEM_INFO}" in
        'CentOS release 6'*)
                SYSTEM='centos6'
                YUM_SOURCE_NAME='centos6-lan'
                ;;
        'Red Hat Enterprise Linux Server release 5'*)
                SYSTEM='rhel5'
                YUM_SOURCE_NAME='RHEL5-lan'
                ;;
        'Debian GNU/Linux 6'*)
                SYSTEM='debian6'
                ;;
        *)
                SYSTEM='unknown'
                echo "This script not support ${SYSTEM_INFO}" 1>&2
                exit 1
                ;;
esac
}

set_install_cmd () {
case "${SYSTEM}" in
        centos6|rhel5)
                INSTALL_CMD='yum --skip-broken --nogpgcheck'
                CONFIG_CMD='chkconfig'
				MODIFY_SYSCONFIG='true'
        ;;
        debian6)
                INSTALL_CMD='apt-get'
                CONFIG_CMD='sysv-rc-conf'
                eval "${INSTALL_CMD} install -y ${CONFIG_CMD}" >/dev/null 2>&1 || eval "echo ${install_cmd} fail! 1>&2;exit 1"
        ;;
        *)
                echo "This script not support ${SYSTEM_INFO}" 1>&2
                exit 1
        ;;
esac
}

install_rsyslog () {
if [ -e /etc/init.d/syslog ];then
        /etc/init.d/syslog status >/dev/null 2>&1 && /etc/init.d/syslog stop >/dev/null 2>&1
        eval "${CONFIG_CMD} syslog off"
fi

if [ ! -e /etc/init.d/rsyslog ];then
       eval "${INSTALL_CMD} install -y rsyslog"
fi

grep 'history.log' /etc/rsyslog.conf >/dev/null 2>&1 ||set_history='fail'
if [ "${set_history}" = 'fail' ];then
        echo 'local4.=debug                                           -/var/log/history.log' >> /etc/rsyslog.conf
        eval "${CONFIG_CMD} rsyslog on"
fi

if [ -e /etc/rsyslog.conf ];then
        grep -E '^#SET Standard timestamp' /etc/rsyslog.conf >/dev/null 2>&1 || set_time='noset'
                if [ "${set_time}" = 'noset' ];then
                        sed -i '/$ActionFileDefaultTemplate/d' /etc/rsyslog.conf
                        echo '#SET Standard timestamp
$template myformat,"%$NOW% %TIMESTAMP% %hostname% %syslogtag% %msg%"
$ActionFileDefaultTemplate myformat' >> /etc/rsyslog.conf
                fi
fi

if [ "${MODIFY_SYSCONFIG}" = 'true' ];then
	if [ -e /etc/sysconfig/rsyslog ];then
		sed -i -r 's/^(SYSLOGD_OPTIONS).*/\1=\"-c 3\"/' /etc/sysconfig/rsyslog
	fi
fi
/etc/init.d/rsyslog restart
}

set_history () {
local his_file='/usr/sbin/get_history.sh'
if [ ! -e "${his_file}" ];then
        test -d /usr/sbin && cd /usr/sbin || exit 1
        wget -q http://${yum_server}/shell/get_history.sh
        chmod +x ${his_file}
fi

grep 'get_history.sh' /etc/crontab >/dev/null 2>&1 || echo "*/10 * * * * root ${his_file} >/dev/null" >>/etc/crontab
}

set_log_server () {
if [ -n "${log_server}" ];then
        grep -E '^#log to syslog server' /etc/rsyslog.conf >/dev/null 2>&1 ||\
        echo "#log to syslog server
*.*            @${log_server}" >> /etc/rsyslog.conf
fi
}

main () {
yum_server='10.10.6.42'
log_server='10.10.6.42'
check_system
set_install_cmd
install_rsyslog
set_history
set_log_server
}

main
