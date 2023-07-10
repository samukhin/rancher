FROM rancher/rancher:v2.3.11
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY exec.yaml /tmp/exec.yaml
  
RUN chmod +x /usr/bin/entrypoint.sh
RUN apt update && apt install wget -y && \
wget --no-check-certificate http://github.com/kubernetes-sigs/kwok/releases/download/v0.3.0/kwokctl-linux-amd64 && \
mv ./kwokctl-linux-amd64 /usr/bin/kwokctl && chmod +x /usr/bin/kwokctl && \
KWOK_KUBE_VERSION=v1.21.14 kwokctl -c /tmp/exec.yaml create cluster

VOLUME /root/.kwok

ENTRYPOINT entrypoint.sh
