FROM centos:centos7
MAINTAINER Ilya Trushchenko inbox@whitehat.com.ua

ENV \
  ZS_DBHost=localhost \
  ZS_DBName=zabbix \
  ZS_DBUser=zabbix \
  ZS_DBPassword=zabbix \
  ZS_DBSocket=/tmp/mysql.sock \
  ZS_DBPort=3306 \
  ZS_DBPartKeepData=90 \
  ZS_DBPartKeepTrends=730 \
  ZS_DBMaintInterval=2

COPY files/ /tmp/

RUN \
    install -m 755 /tmp/run.sh / && \
    install -m 755 /tmp/zbdb_maintenance.sh /usr/sbin/ && \
    install /tmp/zabbix_partitioning.sql /usr/share/ && \
    yum -y update && \
    yum install -y mariadb hostname && \
    yum clean all && \
    rm -rf /tmp/*

# Set TERM env to avoid mysql client error message "TERM environment variable not set" when running from inside the container
ENV TERM xterm

ENTRYPOINT ["/run.sh"]
