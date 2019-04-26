# FROM gcr.io/kaniko-project/executor:v0.9.0
FROM registry.cn-hangzhou.aliyuncs.com/setzero/executor:v0.9.0
FROM maven:3-jdk-8-alpine
ENV TZ="Asia/Shanghai" \
    HELM_PUSH_VERSION="v0.7.1" \
    YQ_VERSION="2.2.1" \
    IMG_VERSION="v0.5.6" \
    HELM_VERSION="v2.13.0" \
    YQ_SHA256="54443f0e9796dfb8423a6e33b8175a0f77b8bb0eb55db820ecb84098db2c0ed4" \
    IMG_SHA256="f5d686465a7463c296e94634bd9597af58544ead924567c9128a4ee352591bf1" \
    HELM_SHA256="15eca6ad225a8279de80c7ced42305e24bc5ac60bb7d96f2d2fa4af86e02c794"

# Add mirror source
RUN cp /etc/apk/repositories /etc/apk/repositories.bak && \
    sed -i 's dl-cdn.alpinelinux.org mirrors.aliyun.com g' /etc/apk/repositories

# Install packages
COPY --from=0 /kaniko/executor /usr/local/bin/kaniko
RUN apk --no-cache add \
        jq \
        git \
        npm \
        gcc \
        python \
        py2-pip \
        openssh \
        openssl \
        musl-dev \
        libffi-dev \
        python2-dev \
        openssl-dev \
        xmlstarlet \
        mysql-client \
        ca-certificates && \
    wget -q -O /usr/bin/yq \
        "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" && \
    echo "${YQ_SHA256}  /usr/bin/yq" | sha256sum -c - && \
    chmod a+x /usr/bin/yq  && \
    wget -q -O /usr/bin/img \
        "https://github.com/genuinetools/img/releases/download/${IMG_VERSION}/img-linux-amd64" && \
    echo "${IMG_SHA256}  /usr/bin/img" | sha256sum -c - && \
    chmod a+x /usr/bin/img  && \
    wget -q -O "/tmp/helm.tar.gz" \
        "https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz" && \
    echo "${HELM_SHA256}  /tmp/helm.tar.gz" | sha256sum -c - && \
    tar xzf "/tmp/helm.tar.gz" -C /tmp && \
    mv /tmp/linux-amd64/helm /usr/bin/helm && \
    rm -r /tmp/* && \
    helm init -c && \
    helm plugin install --version $HELM_PUSH_VERSION https://github.com/chartmuseum/helm-push && \
    pip install --no-cache-dir pymysql==0.9.2 pyyaml==3.13 -i https://mirrors.aliyun.com/pypi/simple/ && \
    npm install -g cnpm && \
    ln -s /usr/bin/img /usr/bin/docker