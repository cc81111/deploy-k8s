#!/bin/bash
cat /opt/k8s-deploy/allnode-pubip|while read line
do
IP=($line)
scp /opt/cert/etcd/*  root@$IP:/opt/etcd/ssl/;
scp /opt/cert/k8s/*  root@$IP:/opt/kubernetes/ssl/;
done
