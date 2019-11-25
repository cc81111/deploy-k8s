#!/bin/bash
cat node-publicip.list|while read line
do
IP=($line)
/usr/bin/expect<<EOF
set timeout 1000000
spawn scp /opt/shell/k8s/cfg/deploy_docker.sh root@$IP:/opt/k8s-deploy/;
expect "#"
spawn ssh root@$IP;
expect "#"
send "chmod a+x /opt/k8s-deploy/deploy_docker.sh\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_docker.sh\r"       
expect "#"
send "exit\r"
send "exit\r"
expect eof
EOF
done


a=$(cat master-publicip.list | grep etcd01 | awk '{print $1}')
A=$(cat master-praviteip.list | grep etcd01 | awk '{print $1}')
B=$(cat master-praviteip.list | grep etcd02 | awk '{print $1}')
C=$(cat master-praviteip.list | grep etcd03 | awk '{print $1}')

/usr/bin/expect<<EOF
set timeout 1000000
spawn scp /opt/shell/k8s/cfg/define_flannel_network.sh root@$a:/opt/k8s-deploy/;
expect "#"
spawn ssh root@$a;
expect "#"
send "chmod a+x /opt/k8s-deploy/define_flannel_network.sh\r"
expect "#"
send "sh /opt/k8s-deploy/define_flannel_network.sh $A $B $C\r"
expect "#"
send "exit\r"
expect eof
EOF
