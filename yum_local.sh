#!/bin/bash

SOURCE_DIR='/etc/yum.repos.d'
my_date=`date -d "now" +"%F"`

if [ -d "${SOURCE_DIR}" ];then
        find ${SOURCE_DIR} -type f -name "*.repo"|grep -Ev 'CENTOS.*-lan.repo|RHEL.*-lan.repo'|\
        while read source_file
        do
                mv "${source_file}" "${source_file}.${my_date}.$$"
        done
fi

echo "[yum_local]
name=yum_local
baseurl=http://yum.kjtprod.com/iso/CentOS6.5-x64
enabled=1
gpgcheck=0" > "${SOURCE_DIR}/yum_local.repo"
yum makecache
