#!/bin/bash

a=$(cat master-publicip.list | grep etcd01 | awk '{print $1}')
b=$(cat master-publicip.list | grep etcd02 | awk '{print $1}')
c=$(cat master-publicip.list | grep etcd03 | awk '{print $1}')

A=$(cat master-praviteip.list | grep etcd01 | awk '{print $1}')
B=$(cat master-praviteip.list | grep etcd02 | awk '{print $1}')
C=$(cat master-praviteip.list | grep etcd03 | awk '{print $1}')

list1="$a $b $c"
list2="$A $B $C"
array1=($list1)
array2=($list2)

count=${#array1[@]}
for i in `seq 1 $count`
do 
publicip=${array1[$i-1]}
paviteip=${array2[$i-1]}


/usr/bin/expect<<EOF
set timeout 1000000
spawn scp /opt/shell/k8s/cfg/deploy_kube-apiserver.sh root@$publicip:/opt/k8s-deploy/;
expect "#"
spawn scp /opt/shell/k8s/cfg/deploy_kube-scheduler.sh root@$publicip:/opt/k8s-deploy/;
expect "#"
spawn scp /opt/shell/k8s/cfg/deploy_kube-controller-manager.sh root@$publicip:/opt/k8s-deploy/;
expect "#"
spawn scp /opt/shell/k8s/bin/kubernetes/server/bin/kube-apiserver root@$publicip:/opt/kubernetes/bin/;
expect "#"
spawn scp /opt/shell/k8s/bin/kubernetes/server/bin/kube-scheduler root@$publicip:/opt/kubernetes/bin/;
expect "#"
spawn scp /opt/shell/k8s/bin/kubernetes/server/bin/kube-controller-manager root@$publicip:/opt/kubernetes/bin/;
expect "#"
spawn scp /opt/shell/k8s/bin/kubernetes/server/bin/kubectl root@$publicip:/opt/kubernetes/bin/;
expect "#"
spawn ssh root@$publicip;
expect "#"
send "chmod a+x /opt/k8s-deploy/{deploy_kube-apiserver.sh,deploy_kube-scheduler.sh,deploy_kube-controller-manager.sh}\r"
expect "#"
send "chmod a+x /opt/kubernetes/bin/{kube-apiserver,kube-scheduler,kube-controller-manager,kubectl}\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_kube-apiserver.sh $paviteip\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_kube-scheduler.sh\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_kube-controller-manager.sh\r"
expect "#"
send "exit\r"
expect eof
EOF
done
