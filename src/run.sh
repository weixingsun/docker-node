#!/usr/bin/env bash
service nginx start
#service ssh   start
cd /opt && /opt/node/bin/node /opt/msg.js 
#> /tmp/log.node 2>&1
