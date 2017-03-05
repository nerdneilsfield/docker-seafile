FROM ubuntu:16.04
MAINTAINER nerdneils
RUN apt-get update && apt-get -y install mariadb-server python2.7 \
    python-setuptools python-imaging python-ldap python-mysqldb  \
    python-memcache python-urllib3 supervisor

RUN locale-gen en_US.UTF-8 en_GB.UTF-8 zh_CN.UTF-8 
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "Asia/Shanghai" > /etc/timezone

RUN mkdir -p /pan
WORKDIR /pan

RUN apt-get -y install wget
RUN wget http://seafile-downloads.oss-cn-shanghai.aliyuncs.com/seafile-server_6.0.8_x86-64.tar.gz
RUN tar -xvf seafile-server_* && mkdir installed && mv seafile-server_* installed

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY 01.png /pan/01.png


EXPOSE 8000


