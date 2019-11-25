#!/bin/bash
cat /opt/k8s-deploy/node-publicip.list|while read line
do
IP=($line)
scp /opt/k8s-deploy/*.kubeconfig  root@$IP:/opt/kubernetes/cfg/;
chmod a+x bootstrap.kubeconfig 
chmod a+x kube-proxy.kubeconfig
done
