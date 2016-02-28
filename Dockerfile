FROM nginx:latest
MAINTAINER Weixing Sun <weixing.sun@gmail.com>
ENV buildDeps "gcc make python g++"
RUN apt-get -qq update && apt-get -y install openssh-server wget $buildDeps
RUN mkdir /var/run/sshd && echo 'root:ws206771' | chpasswd && \
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd 
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
ENV NODE_VER v5.7.0-linux-x64
RUN cd /opt && wget https://nodejs.org/dist/latest/node-$NODE_VER.tar.gz && \
  tar -xzf node-$NODE_VER.tar.gz && mv node-$NODE_VER node && \
  cd /usr/local/bin && ln -s /opt/node/bin/* . && rm -f /opt/node*.tar.gz
WORKDIR /opt
RUN /opt/node/bin/npm install --save express couchbase body-parser
COPY conf/sysctl.conf /etc/sysctl.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/sites.default /etc/nginx/sites-enabled/default
COPY src/msg.js /opt/msg.js
COPY src/run.sh /run.sh
#RUN service nginx restart
RUN apt-get purge -y --auto-remove $buildDeps
ENTRYPOINT ["/run.sh"]
EXPOSE 22 80
#CMD ["/usr/sbin/sshd", "-D"]
#CMD ["/bin/bash", ""]
#docker build -t wsun/nginx_node .
#docker run --name node -d --ulimit nofile=40960:40960 -p 80:80 -p 22:22 -i wsun/nginx_node
#docker run --name node -d --ulimit nofile=40960:40960 -p 80:80 -i wsun/nginx_node
