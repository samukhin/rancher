#!/bin/bash
set -e

k3s server --no-deploy traefik --no-deploy servicelb --no-deploy metrics-server --no-deploy local-storage --node-name local-node --log ./k3s.log --disable-agent&

while [ ! -f /etc/rancher/k3s/k3s.yaml ]
do
echo "Not k3s.yaml"
sleep 1
done

kubectl apply -f - <<EOF
apiVersion: v1
kind: Node
metadata:
  annotations:
    node.alpha.kubernetes.io/ttl: "0"
    kwok.x-k8s.io/node: fake
  labels:
    beta.kubernetes.io/arch: amd64
    beta.kubernetes.io/os: linux
    kubernetes.io/arch: amd64
    kubernetes.io/hostname: kwok-node-0
    kubernetes.io/os: linux
    kubernetes.io/role: agent
    node-role.kubernetes.io/agent: ""
    type: kwok
  name: local
EOF

tini -- rancher --http-listen-port=80 --https-listen-port=443 --audit-log-path=${AUDIT_LOG_PATH} --audit-level=${AUDIT_LEVEL} --audit-log-maxage=${AUDIT_LOG_MAXAGE} --audit-log-maxbackup=${AUDIT_LOG_MAXBACKUP} --audit-log-maxsize=${AUDIT_LOG_MAXSIZE} --add-local=true --kubeconfig=/etc/rancher/k3s/k3s.yaml --features fleet=false&

kwok \
  --kubeconfig=/etc/rancher/k3s/k3s.yaml \
  --manage-all-nodes=true \
  --disregard-status-with-annotation-selector=kwok.x-k8s.io/status=custom \
  --disregard-status-with-label-selector= \
  --cidr=10.0.0.1/24 \
  --node-ip=10.0.0.1
