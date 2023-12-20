set -x

apt-get update && apt-get install -y git curl ca-certificates unzip xz-utils && \
    useradd rancher && \
    mkdir -p /var/lib/rancher/etcd /var/lib/cattle /opt/jail /opt/drivers/management-state/bin && \
    chown -R rancher /var/lib/rancher /var/lib/cattle /usr/local/bin

mkdir /root/.kube && \
    ln -s /etc/rancher/k3s/k3s.yaml /root/.kube/k3s.yaml  && \
    ln -s /etc/rancher/k3s/k3s.yaml /root/.kube/config && \
    ln -s /usr/bin/rancher /usr/bin/reset-password && \
    ln -s /usr/bin/rancher /usr/bin/ensure-default-admin && \
    rm -f /bin/sh && ln -s /bin/bash /bin/sh

cd /var/lib/rancher


export ARCH=amd64
export IMAGE_REPO=rancher
export SYSTEM_CHART_DEFAULT_BRANCH=release-v2.5
export CHART_DEFAULT_BRANCH=release-v2.5
export PARTNER_CHART_DEFAULT_BRANCH=main
# kontainer-driver-metadata branch to be set for specific branch other than dev/master, logic at rancher/rancher/pkg/settings/setting.go
export RANCHER_METADATA_BRANCH=release-v2.5

export CATTLE_SYSTEM_CHART_DEFAULT_BRANCH=$SYSTEM_CHART_DEFAULT_BRANCH
export CATTLE_CHART_DEFAULT_BRANCH=$CHART_DEFAULT_BRANCH
export CATTLE_PARTNER_CHART_DEFAULT_BRANCH=$PARTNER_CHART_DEFAULT_BRANCH
export CATTLE_HELM_VERSION=v2.16.8-rancher1
export CATTLE_K3S_VERSION=v1.19.13+k3s1
export CATTLE_MACHINE_VERSION=v0.15.0-rancher55
export CATTLE_ETCD_VERSION=v3.4.3
export CATTLE_CHANNELSERVER_VERSION=v0.5.0
export LOGLEVEL_VERSION=v0.1.3
export TINI_VERSION=v0.18.0
export TELEMETRY_VERSION=v0.5.14
export KUBECTL_VERSION=v1.19.7
export DOCKER_MACHINE_LINODE_VERSION=v0.1.8
export LINODE_UI_DRIVER_VERSION=v0.3.0
export RANCHER_METADATA_BRANCH=${RANCHER_METADATA_BRANCH}
export HELM_VERSION=v3.3.1
export KUSTOMIZE_VERSION=v3.5.4

# System charts minimal version
export CATTLE_FLEET_MIN_VERSION=0.3.900
export CATTLE_RANCHER_OPERATOR_MIN_VERSION=0.1.500
export CATTLE_RANCHER_WEBHOOK_MIN_VERSION=0.1.500

mkdir -p /var/lib/rancher-data/local-catalogs/system-library && \
    mkdir -p /var/lib/rancher-data/local-catalogs/library && \
    mkdir -p /var/lib/rancher-data/local-catalogs/helm3-library && \
    mkdir -p /var/lib/rancher-data/local-catalogs/v2 && \
    git clone -b $CATTLE_SYSTEM_CHART_DEFAULT_BRANCH --single-branch https://github.com/rancher/system-charts /var/lib/rancher-data/local-catalogs/system-library && \
    # Charts need to be copied into the sha256 value of git url computed in https://github.com/rancher/rancher/blob/5ebda9ac23c06e9647b586ec38aa51cc9ff9b031/pkg/catalogv2/git/download.go#L102 to create a unique folder per url
    git clone -b $CATTLE_CHART_DEFAULT_BRANCH --depth 1 https://git.rancher.io/charts /var/lib/rancher-data/local-catalogs/v2/rancher-charts/4b40cac650031b74776e87c1a726b0484d0877c3ec137da0872547ff9b73a721/ && \
    git clone -b $CATTLE_PARTNER_CHART_DEFAULT_BRANCH --depth 1 https://git.rancher.io/partner-charts /var/lib/rancher-data/local-catalogs/v2/rancher-partner-charts/8f17acdce9bffd6e05a58a3798840e408c4ea71783381ecd2e9af30baad65974 && \
    git clone -b master --single-branch https://github.com/rancher/charts /var/lib/rancher-data/local-catalogs/library && \
    git clone -b master --single-branch https://github.com/rancher/helm3-charts /var/lib/rancher-data/local-catalogs/helm3-library

curl -sLf https://github.com/rancher/machine/releases/download/${CATTLE_MACHINE_VERSION}/rancher-machine-${ARCH}.tar.gz | tar xvzf - -C /usr/bin && \
    curl -sLf https://github.com/rancher/loglevel/releases/download/${LOGLEVEL_VERSION}/loglevel-${ARCH}-${LOGLEVEL_VERSION}.tar.gz | tar xvzf - -C /usr/bin && \
    curl -LO https://github.com/linode/docker-machine-driver-linode/releases/download/${DOCKER_MACHINE_LINODE_VERSION}/docker-machine-driver-linode_linux-amd64.zip && \
    unzip docker-machine-driver-linode_linux-amd64.zip -d /opt/drivers/management-state/bin && \
    rm docker-machine-driver-linode_linux-amd64.zip

export TINI_URL_amd64=https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
    TINI_URL_arm64=https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-arm64 \
    TINI_URL=TINI_URL_${ARCH}

export HELM_URL_V2_amd64=https://github.com/rancher/helm/releases/download/${CATTLE_HELM_VERSION}/rancher-helm \
    HELM_URL_V2_arm64=https://github.com/rancher/helm/releases/download/${CATTLE_HELM_VERSION}/rancher-helm-arm64 \
    HELM_URL_V2=HELM_URL_V2_${ARCH} \
    HELM_URL_V3=https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz \
    TILLER_URL_amd64=https://github.com/rancher/helm/releases/download/${CATTLE_HELM_VERSION}/rancher-tiller \
    TILLER_URL_arm64=https://github.com/rancher/helm/releases/download/${CATTLE_HELM_VERSION}/rancher-tiller-arm64 \
    TILLER_URL=TILLER_URL_${ARCH} \
    K3S_URL_amd64=https://github.com/rancher/k3s/releases/download/${CATTLE_K3S_VERSION}/k3s \
    K3S_URL_arm64=https://github.com/rancher/k3s/releases/download/${CATTLE_K3S_VERSION}/k3s-arm64 \
    K3S_URL=K3S_URL_${ARCH} \
    CHANNELSERVER_URL_amd64=https://github.com/rancher/channelserver/releases/download/${CATTLE_CHANNELSERVER_VERSION}/channelserver-amd64 \
    CHANNELSERVER_URL_arm64=https://github.com/rancher/channelserver/releases/download/${CATTLE_CHANNELSERVER_VERSION}/channelserver-arm64 \
    CHANNELSERVER_URL=CHANNELSERVER_URL_${ARCH} \
    ETCD_URL_amd64=https://github.com/etcd-io/etcd/releases/download/${CATTLE_ETCD_VERSION}/etcd-${CATTLE_ETCD_VERSION}-linux-amd64.tar.gz \
    ETCD_URL_arm64=https://github.com/etcd-io/etcd/releases/download/${CATTLE_ETCD_VERSION}/etcd-${CATTLE_ETCD_VERSION}-linux-arm64.tar.gz \
    ETCD_URL=ETCD_URL_${ARCH} \
    KUSTOMIZE_URL_amd64=https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
    KUSTOMIZE_URL_arm64=https://github.com/brendarearden/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_arm64.tar.gz \
    KUSTOMIZE_URL=KUSTOMIZE_URL_${ARCH}

if [ "${ARCH}" == "arm64" ]; then \
    curl -sLf ${!KUSTOMIZE_URL} | tar xvzf - --strip-components=1 -C /usr/bin; else \
    curl -sOL ${!KUSTOMIZE_URL} && \
    sleep 1 && \
    tar xzf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz -C /usr/bin && \
    rm kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz; \
    fi

# set up helm 2
curl -sLf ${!HELM_URL_V2} > /usr/bin/rancher-helm && \
    curl -sLf ${!TILLER_URL} > /usr/bin/rancher-tiller && \
    ln -s /usr/bin/rancher-helm /usr/bin/helm && \
    ln -s /usr/bin/rancher-tiller /usr/bin/tiller && \
    chmod +x /usr/bin/rancher-helm /usr/bin/rancher-tiller

# set up helm 3
curl ${HELM_URL_V3} | tar xvzf - --strip-components=1 -C /usr/bin && \
    mv /usr/bin/helm /usr/bin/helm_v3 && \
    chmod +x /usr/bin/kustomize

curl -sLf ${!TINI_URL} > /usr/bin/tini && \
    curl -sLf ${!CHANNELSERVER_URL} > /usr/bin/channelserver && \
    curl -sLf ${!K3S_URL} > /usr/bin/k3s && \
    mkdir -p /var/lib/rancher/k3s/agent/images/ && \
    curl -sfL ${!ETCD_URL} | tar xvzf - --strip-components=1 -C /usr/bin/ etcd-${CATTLE_ETCD_VERSION}-linux-${ARCH}/etcd etcd-${CATTLE_ETCD_VERSION}-linux-${ARCH}/etcdctl && \
    curl -sLf https://github.com/rancher/telemetry/releases/download/${TELEMETRY_VERSION}/telemetry-${ARCH} > /usr/bin/telemetry && \
    curl -sLf https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl > /usr/bin/kubectl && \
    chmod +x /usr/bin/tini /usr/bin/telemetry /usr/bin/k3s /usr/bin/kubectl /usr/bin/channelserver && \
    mkdir -p /var/lib/rancher-data/driver-metadata

export CATTLE_UI_VERSION=2.5.16
export CATTLE_DASHBOARD_UI_VERSION=v2.5.16
export CATTLE_CLI_VERSION=v2.4.14
# Please update the api-ui-version in pkg/settings/settings.go when updating the version here.
export CATTLE_API_UI_VERSION=1.1.9

mkdir -p /var/log/auditlog
export AUDIT_LOG_PATH=/var/log/auditlog/rancher-api-audit.log
export AUDIT_LOG_MAXAGE=10
export AUDIT_LOG_MAXBACKUP=10
export AUDIT_LOG_MAXSIZE=100
export AUDIT_LEVEL=0

mkdir -p /usr/share/rancher/ui && \
    cd /usr/share/rancher/ui && \
    curl -sL https://releases.rancher.com/ui/${CATTLE_UI_VERSION}.tar.gz | tar xvzf - --strip-components=1 && \
    mkdir -p assets/rancher-ui-driver-linode && \
    cd assets/rancher-ui-driver-linode && \
    curl -O https://linode.github.io/rancher-ui-driver-linode/releases/${LINODE_UI_DRIVER_VERSION}/component.js && \
    curl -O https://linode.github.io/rancher-ui-driver-linode/releases/${LINODE_UI_DRIVER_VERSION}/component.css && \
    curl -O https://linode.github.io/rancher-ui-driver-linode/releases/${LINODE_UI_DRIVER_VERSION}/linode.svg && \
    mkdir -p /usr/share/rancher/ui/api-ui && \
    cd /usr/share/rancher/ui/api-ui && \
    curl -sL https://releases.rancher.com/api-ui/${CATTLE_API_UI_VERSION}.tar.gz | tar xvzf - --strip-components=1 && \
    mkdir -p /usr/share/rancher/ui-dashboard/dashboard && \
    cd /usr/share/rancher/ui-dashboard/dashboard && \
    curl -sL https://releases.rancher.com/dashboard/${CATTLE_DASHBOARD_UI_VERSION}.tar.gz | tar xvzf - --strip-components=2 && \
    ln -s dashboard/index.html ../index.html

export CATTLE_CLI_URL_DARWIN=https://releases.rancher.com/cli2/${CATTLE_CLI_VERSION}/rancher-darwin-amd64-${CATTLE_CLI_VERSION}.tar.gz
export CATTLE_CLI_URL_LINUX=https://releases.rancher.com/cli2/${CATTLE_CLI_VERSION}/rancher-linux-amd64-${CATTLE_CLI_VERSION}.tar.gz
export CATTLE_CLI_URL_WINDOWS=https://releases.rancher.com/cli2/${CATTLE_CLI_VERSION}/rancher-windows-386-${CATTLE_CLI_VERSION}.zip

export VERSION=dev
export CATTLE_SERVER_VERSION=${VERSION}
cp $HOME/entrypoint.sh rancher /usr/bin/
cp $HOME/kustomize.sh /usr/bin/
cp $HOME/jailer.sh /usr/bin/
#cp k3s-airgap-images.tar /var/lib/rancher/k3s/agent/images/
chmod +x /usr/bin/entrypoint.sh
chmod +x /usr/bin/kustomize.sh

cp $HOME/data.json /var/lib/rancher-data/driver-metadata/

export CATTLE_AGENT_IMAGE=${IMAGE_REPO}/rancher-agent:${VERSION}
export CATTLE_SERVER_IMAGE=${IMAGE_REPO}/rancher
export ETCD_UNSUPPORTED_ARCH=${ARCH}
export ETCDCTL_API=3

export SSL_CERT_DIR=/etc/rancher/ssl
