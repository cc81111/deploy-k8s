#!/bin/bash
#----------------------------master------------------------
cat master-publicip.list|while read line
do
IP=($line)
/usr/bin/expect<<EOF
set timeout 1000000
spawn ssh root@$IP;                 
expect "#"       
send "sudo mkdir -pv /opt/cert/{etcd,k8s}/\r"
send "sudo mkdir  -pv /opt/kubernetes/{bin,cfg,ssl}\r"
send "sudo mkdir  -pv /opt/k8s-deploy\r"
send "sudo mkdir -pv /opt/etcd/{bin,cfg,ssl}\r"
expect "#"
send "exit\r"
expect eof
EOF
done

#----------------------------node------------------------

cat node-publicip.list|while read line
do
IP=($line)
/usr/bin/expect<<EOF
set timeout 1000000
spawn ssh root@$IP;
expect "#"
send "sudo mkdir  -pv /opt/k8s-deploy\r"
send "sudo mkdir  -pv /opt/kubernetes/{bin,cfg,ssl}\r"
send "sudo mkdir  -pv /opt/etcd/ssl/\r"
expect "#"
send "exit\r"
expect eof
EOF
done
