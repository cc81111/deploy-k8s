#!/bin/bash
a=$(cat master-publicip.list | grep etcd01 | awk '{print $1}')
b=$(cat master-publicip.list | grep etcd02 | awk '{print $1}')
c=$(cat master-publicip.list | grep etcd03 | awk '{print $1}')

A=$(cat master-praviteip.list | grep etcd01 | awk '{print $1}')
B=$(cat master-praviteip.list | grep etcd02 | awk '{print $1}')
C=$(cat master-praviteip.list | grep etcd03 | awk '{print $1}')



list1="$a $b $c"
list2="etcd01 etcd02 etcd03"
list3="$A $B $C"
array1=($list1)
array2=($list2)
array3=($list3)

count=${#array1[@]}
for i in `seq 1 $count`
do 
publicip=${array1[$i-1]}
ETCD_NAME=${array2[$i-1]}
paviteip=${array3[$i-1]}

/usr/bin/expect<<EOF
set timeout 1000000
spawn scp /opt/shell/k8s/cfg/deploy_etcd.sh root@$publicip:/opt/k8s-deploy/;
expect "#"
spawn scp /opt/shell/k8s/master-praviteip.list root@$publicip:/opt/k8s-deploy/;
expect "#"
spawn scp /opt/shell/k8s/bin/etcd-v3.3.12-linux-amd64/etcdctl root@$publicip:/opt/etcd/bin 
expect "#"
spawn scp /opt/shell/k8s/bin/etcd-v3.3.12-linux-amd64/etcd root@$publicip:/opt/etcd/bin
expect "#"
spawn ssh root@$publicip;                 
expect "#"       
send "chmod a+x /opt/k8s-deploy/deploy_etcd.sh\r"
expect "#"
send "chmod a+x /opt/k8s-deploy/master-praviteip.list\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_etcd.sh $ETCD_NAME $paviteip\r"       
expect "#"
send "exit\r"
expect eof
EOF
done

