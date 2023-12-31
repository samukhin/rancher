#!/bin/bash
set -e

tini -- rancher --http-listen-port=80 --https-listen-port=443 --audit-log-path=${AUDIT_LOG_PATH} --audit-level=${AUDIT_LEVEL} --audit-log-maxage=${AUDIT_LOG_MAXAGE} --audit-log-maxbackup=${AUDIT_LOG_MAXBACKUP} --audit-log-maxsize=${AUDIT_LOG_MAXSIZE} --add-local=true&
while [ ! -f /var/lib/rancher/management-state/cred/kubeconfig.yaml ]
do
echo "Not k3s.yaml"
sleep 1
done
kwok \
  --kubeconfig=/var/lib/rancher/management-state/cred/kubeconfig.yaml \
  --manage-all-nodes=true
  --disregard-status-with-annotation-selector=kwok.x-k8s.io/status=custom \
  --disregard-status-with-label-selector= \
  --cidr=10.0.0.1/24 \
  --node-ip=10.0.0.1
