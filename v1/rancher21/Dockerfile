FROM rancher/rancher:v2.1.14

RUN apt update && apt install wget -y && apt clean && \
wget --no-check-certificate http://github.com/kubernetes-sigs/kwok/releases/download/v0.3.0/kwok-linux-amd64 && \
chmod +x kwok-linux-amd64 && mv ./kwok-linux-amd64 /usr/bin/kwok

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT entrypoint.sh
