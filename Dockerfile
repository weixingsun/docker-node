FROM ubuntu:latest
MAINTAINER Weixing Sun <weixing.sun@gmail.com>
RUN apt-get -qq update && apt-get -y install openssh-server wget nginx python make gcc g++ 
RUN mkdir /var/run/sshd && echo 'root:ws206771' | chpasswd && \
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd 
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN cd /opt && wget https://nodejs.org/dist/v4.3.1/node-v4.3.1-linux-x64.tar.gz && \
  tar -xzf node-v4.3.1-linux-x64.tar.gz && mv node-v4.3.1-linux-x64 node && \
  cd /usr/local/bin && ln -s /opt/node/bin/* . && rm -f /opt/node-v4.3.1-linux-x64.tar.gz
WORKDIR /opt
RUN /opt/node/bin/npm install --save express couchbase body-parser
COPY conf/sysctl.conf /etc/sysctl.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/sites.default /etc/nginx/sites-enabled/default
COPY src/msg.js /opt/msg.js
COPY src/run.sh /run.sh
#RUN service nginx restart

ENTRYPOINT ["/run.sh"]
EXPOSE 22 80
#CMD ["/usr/sbin/sshd", "-D"]
#CMD ["/bin/bash", ""]
#docker build -t wsun/nginx_node .
#docker run --name node -d --ulimit nofile=40960:40960 -p 80:80 -p 22:22 -i wsun/nginx_node
#docker run --name node -d --ulimit nofile=40960:40960 -p 80:80 -i wsun/nginx_node
