#!/bin/bash

### Add User ###
useradd app
echo "suixingpay_app" |passwd --stdin app

### Install rpm ###
rpm -Uvh http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
yum -y install tmux sysstat

### Install jdk ###
su - app -c "mkdir /home/app/shell"
su - app -c "wget http://yum.suixingpay.local/shell/install_jdk.sh -P /home/app/shell"
su - app -c "sh /home/app/shell/install_jdk.sh -v 1.7 -p x64"
