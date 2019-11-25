#!/bin/bash
A=$(cat /opt/k8s-deploy/master-praviteip.list | grep etcd01 | awk '{print $1}')
B=$(cat /opt/k8s-deploy/master-praviteip.list | grep etcd02 | awk '{print $1}')
C=$(cat /opt/k8s-deploy/master-praviteip.list | grep etcd03 | awk '{print $1}')

ETCD_NAME=$1
ETCD_IP=$2

#---------
cat > /opt/etcd/cfg/etcd<<EOF
#[Member]
ETCD_NAME="${ETCD_NAME}"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://${ETCD_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${ETCD_IP}:2379"
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_IP}:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_IP}:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://$A:2380,etcd02=https://$B:2380,etcd03=https://$C:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF
#---------
cat > /usr/lib/systemd/system/etcd.service<<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=/opt/etcd/cfg/etcd
ExecStart=/opt/etcd/bin/etcd \\
--name=\${ETCD_NAME} \\
--data-dir=\${ETCD_DATA_DIR} \\
--listen-peer-urls=\${ETCD_LISTEN_PEER_URLS} \\
--listen-client-urls=\${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \\
--advertise-client-urls=\${ETCD_ADVERTISE_CLIENT_URLS} \\
--initial-advertise-peer-urls=\${ETCD_INITIAL_ADVERTISE_PEER_URLS} \\
--initial-cluster=\${ETCD_INITIAL_CLUSTER} \\
--initial-cluster-token=\${ETCD_INITIAL_CLUSTER_TOKEN} \\
--initial-cluster-state=new \\
--cert-file=/opt/etcd/ssl/server.pem \\
--key-file=/opt/etcd/ssl/server-key.pem \\
--peer-cert-file=/opt/etcd/ssl/server.pem \\
--peer-key-file=/opt/etcd/ssl/server-key.pem \\
--trusted-ca-file=/opt/etcd/ssl/ca.pem \\
--peer-trusted-ca-file=/opt/etcd/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
#---------
systemctl daemon-reload
systemctl start etcd
systemctl enable etcd
