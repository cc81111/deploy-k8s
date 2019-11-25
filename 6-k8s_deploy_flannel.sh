#!/bin/bash

A=$(cat master-praviteip.list | grep etcd01 | awk '{print $1}')
B=$(cat master-praviteip.list | grep etcd02 | awk '{print $1}')
C=$(cat master-praviteip.list | grep etcd03 | awk '{print $1}')

cat node-publicip.list|while read line
do
IP=($line)


/usr/bin/expect<<EOF
set timeout 1000000
spawn scp /opt/shell/k8s/bin/flannel-v0.10.0-linux-amd64/flanneld root@$IP:/opt/kubernetes/bin/;
expect "#"
spawn scp /opt/shell/k8s/bin/flannel-v0.10.0-linux-amd64/mk-docker-opts.sh root@$IP:/opt/kubernetes/bin;
expect "#"
spawn scp /opt/shell/k8s/cfg/deploy_flannel.sh root@$IP:/opt/k8s-deploy/;
expect "#"
spawn ssh root@$IP;
expect "#"
send "chmod a+x /opt/k8s-deploy/deploy_flannel.sh\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_flannel.sh $A $B $C\r"
expect "#"
send "exit\r"
expect eof
EOF
done
