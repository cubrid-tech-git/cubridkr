FROM centos:7

MAINTAINER Joo Youngjin <youngjinj@cubrid.com>

ENV CUBRID_VERSION 10.1.2
ENV CUBRID_BUILD_VERSION 10.1.2.7694-64632b2

RUN yum install -y epel-release; \
    yum update -y; \
    yum install -y sudo \
                   java-1.8.0-openjdk-devel; \
    yum clean all;

RUN localedef -f UTF-8 -i ko_KR ko_KR.utf8; \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

ENV LANG ko_KR.utf8

RUN mkdir /docker-entrypoint-initdb.d

RUN useradd cubrid; \
    sed 102s/#\ %wheel/%wheel/g -i /etc/sudoers; \
    sed s/wheel:x:10:/wheel:x:10:cubrid/g -i /etc/group; \
    sed -e '61 i\cubrid\t\t soft\t nofile\t\t 65536 \
    cubrid\t\t hard\t nofile\t\t 65536 \
    cubrid\t\t soft\t core\t\t 0 \
    cubrid\t\t hard\t core\t\t 0\n' -i /etc/security/limits.conf; \
    echo -e "\ncubrid     soft    nproc     16384\ncubrid     hard    nproc     16384" >> /etc/security/limits.d/20-nproc.conf

RUN curl -o /home/cubrid/CUBRID-$CUBRID_BUILD_VERSION-Linux.x86_64.tar.gz -O http://ftp.cubrid.org/CUBRID_Engine/$CUBRID_VERSION/CUBRID-$CUBRID_BUILD_VERSION-Linux.x86_64.tar.gz > /dev/null 2>&1 \
    && tar -zxf /home/cubrid/CUBRID-$CUBRID_BUILD_VERSION-Linux.x86_64.tar.gz -C /home/cubrid \
    && mkdir -p /home/cubrid/CUBRID/databases /home/cubrid/CUBRID/tmp /home/cubrid/CUBRID/var/CUBRID_SOCK

COPY cubrid.sh /home/cubrid/

RUN echo ''; \
    echo 'umask 077' >> /home/cubrid/.bash_profile; \
    echo ''; \
    echo '. /home/cubrid/cubrid.sh' >> /home/cubrid/.bash_profile; \
    chown -R cubrid:cubrid /home/cubrid

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh; \
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

VOLUME /home/cubrid/CUBRID/databases

EXPOSE 1523 8001 30000 33000

ENTRYPOINT ["docker-entrypoint.sh"]
