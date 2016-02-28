FROM nginx:latest
#MAINTAINER Weixing Sun <weixing.sun@gmail.com>
COPY conf/sysctl.conf conf/limit.conf conf/nginx.conf conf/sites.default src/msg.js src/run.sh /opt/
ENV NODE_VER=v5.7.0-linux-x64 buildDeps="gcc make python g++" NOTVISIBLE="in users profile"
RUN apt-get -qq update && apt-get -y install openssh-server wget $buildDeps && \
    mkdir /var/run/sshd && echo 'root:ws206771' | chpasswd && \
    echo "export VISIBLE=now" >> /etc/profile && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    cd /opt && wget https://nodejs.org/dist/latest/node-$NODE_VER.tar.gz && \
    tar -xzf node-$NODE_VER.tar.gz && mv node-$NODE_VER node && \
    cd /usr/local/bin && ln -s /opt/node/bin/* . && rm -f /opt/node*.tar.gz && \
    cd /opt && /opt/node/bin/npm install --save express couchbase body-parser && \
    apt-get purge -y --auto-remove $buildDeps && \
    mv /opt/sysctl.conf /etc/ && mv /opt/limit.conf /etc/security/limits.d/ && \
    mv /opt/nginx.conf /etc/nginx/ && mv /opt/sites.default /etc/nginx/ && \
    mkdir /www && echo "" > /www/index.html
ENTRYPOINT ["/opt/run.sh"]
EXPOSE 80
#EXPOSE 22 80
#docker build -t wsun/nginx_node .
#docker run --name node -d --ulimit nofile=40960:40960 -p 80:80 -p 22:22 -i wsun/nginx_node
