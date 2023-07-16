#!/bin/bash
set -e

#kwokctl delete cluster
#KWOK_KUBE_VERSION=v1.21.14 kwokctl -c /tmp/exec.yaml create cluster
kwokctl start cluster
kwokctl get kubeconfig > /tmp/config
tini -- rancher --http-listen-port=80 --https-listen-port=443 --audit-log-path=${AUDIT_LOG_PATH} --audit-level=${AUDIT_LEVEL} --audit-log-maxage=${AUDIT_LOG_MAXAGE} --audit-log-maxbackup=${AUDIT_LOG_MAXBACKUP} --audit-log-maxsize=${AUDIT_LOG_MAXSIZE} --kubeconfig=/tmp/config --add-local=true
