#!/bin/bash
#执行脚本前，确保master01和master02、03免密登录
#脚本遗留问题etcd+k8s_cert.sh中的etcd的IP没有改成变量
a=$(cat master-publicip.list | grep etcd01 | awk '{print $1}')
/usr/bin/expect<<EOF
set timeout 1000000
spawn scp /opt/shell/k8s/cfg/etcd+k8s_cert.sh root@$a:/opt/k8s-deploy/;
spawn scp /opt/shell/k8s/cfg/scp_cert.sh root@$a:/opt/k8s-deploy/;
spawn scp /opt/shell/k8s/allnode-pubip root@$a:/opt/k8s-deploy/;
spawn ssh root@$a;
expect "#"       
send "yum install wget -y\r"
send "yum install expect -y\r"
expect "#"
send "chmod a+x /opt/k8s-deploy/{etcd+k8s_cert.sh,scp_cert.sh,allnode-pubip}\r"
expect "#"
send "sh /opt/k8s-deploy/etcd+k8s_cert.sh\r"
expect "#"
send "sh /opt/k8s-deploy/scp_cert.sh\r"
expect "#"
send "exit\r"
expect eof
