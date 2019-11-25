#!/bin/bash
#----------------master01创建kubeconfig--------------------
a=$(cat master-publicip.list | grep etcd01 | awk '{print $1}')
A=$(cat master-praviteip.list | grep etcd01 | awk '{print $1}')

/usr/bin/expect<<EOF
set timeout 1000000
spawn scp /opt/shell/k8s/cfg/deploy_kubelet-bootstrap.sh root@$a:/opt/k8s-deploy/;
expect "#"
spawn ssh root@$a;
send "chmod a+x /opt/k8s-deploy/deploy_kubelet-bootstrap.sh\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_kubelet-bootstrap.sh $A\r"
send "exit\r"
expect eof
EOF

#----------------kubeconfig拷贝到所有node节点--------------------

/usr/bin/expect<<EOF
set timeout 1000000
spawn scp /opt/shell/k8s/cfg/scp_kubeconfig.sh root@$a:/opt/k8s-deploy/;
expect "#"
spawn scp /opt/shell/k8s/node-publicip.list root@$a:/opt/k8s-deploy/;
spawn ssh root@$a;
expect "#"
send "chmod a+x /opt/k8s-deploy/{scp_kubeconfig.sh,node-publicip.list}\r"
expect "#"
send "sh /opt/k8s-deploy/scp_kubeconfig.sh\r"
expect "#"
send "exit\r"
expect eof
EOF




#--------------------node节点部署kubelet & kube-proxy------------------

a=$(cat node-publicip.list | grep node01 | awk '{print $1}')
b=$(cat node-publicip.list | grep node02 | awk '{print $1}')
c=$(cat node-publicip.list | grep node03 | awk '{print $1}')

A=$(cat node-praviteip.list | grep node01 | awk '{print $1}')
B=$(cat node-praviteip.list | grep node02 | awk '{print $1}')
C=$(cat node-praviteip.list | grep node03 | awk '{print $1}')

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
spawn scp /opt/shell/k8s/bin/kubernetes/server/bin/kubelet root@$publicip:/opt/kubernetes/bin/;
expect "#"
spawn scp /opt/shell/k8s/bin/kubernetes/server/bin/kube-proxy root@$publicip:/opt/kubernetes/bin/;
expect "#"
spawn scp /opt/shell/k8s/cfg/deploy_kubelet.sh root@$publicip:/opt/k8s-deploy/;
expect "#"
spawn scp /opt/shell/k8s/cfg/deploy_kube-proxy.sh root@$publicip:/opt/k8s-deploy/;
expect "#"
spawn ssh root@$publicip;
expect "#"
send "chmod a+x /opt/k8s-deploy/{deploy_kubelet.sh,deploy_kube-proxy.sh}\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_kubelet.sh $paviteip\r"
expect "#"
send "sh /opt/k8s-deploy/deploy_kube-proxy.sh $paviteip\r"
expect "#"
send "exit\r"
expect eof
EOF
done




