FROM centos:7

MAINTAINER Joo Youngjin <youngjinj@cubrid.com>

ENV CUBRID_VERSION 10.1.2

RUN yum install -y epel-release; \
    yum update -y; \
    yum install -y sudo \
                   vim \
                   which \
                   net-tools \
                   telnet \
                   nc \
                   wget \
                   expect \
                   openssh-server \
                   openssh-clients \
                   sshpass \
                   java-1.8.0-openjdk-devel \
                   git \
                   cmake \
                   gcc-c++ \
                   systemtap \
                   systemtap-sdt-devel \
                   bison \
                   flex \
                   ncurses-devel \
                   ant \
                   elfutils-libelf-devel \
                   libtool \
                   rpm-build \
                   gdb \
                   ctags \
                   cscope; \
    yum clean all;

RUN localedef -f UTF-8 -i ko_KR ko_KR.utf8; \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

ENV LANG ko_KR.utf8

RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ""; \
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -t ecdsa -N ""; \
    ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N ""; \
    chmod u+s /usr/bin/ping

RUN mkdir /docker-entrypoint-initdb.d

RUN useradd cubrid; \
    sed 102s/#\ %wheel/%wheel/g -i /etc/sudoers; \
    sed s/wheel:x:10:/wheel:x:10:cubrid/g -i /etc/group; \
    sed -e '61 i\cubrid\t\t soft\t nofile\t\t 65536 \
    cubrid\t\t hard\t nofile\t\t 65536 \
    cubrid\t\t soft\t core\t\t 0 \
    cubrid\t\t hard\t core\t\t 0\n' -i /etc/security/limits.conf; \
    echo -e "\ncubrid     soft    nproc     16384\ncubrid     hard    nproc     16384" >> /etc/security/limits.d/20-nproc.conf

RUN curl -L -o /home/cubrid/v${CUBRID_VERSION}.tar.gz -O https://github.com/CUBRID/cubrid/archive/v${CUBRID_VERSION}.tar.gz \
    && tar -zxf /home/cubrid/v${CUBRID_VERSION}.tar.gz -C /home/cubrid

RUN cd /home/cubrid/cubrid-${CUBRID_VERSION} && ./build.sh -m debug -p /home/cubrid/CUBRID -j /usr/lib/jvm/java build \
    && echo 'java_stored_procedure=y' >> /home/cubrid/CUBRID/conf/cubrid.conf \
    && mkdir -p /home/cubrid/CUBRID/databases /home/cubrid/CUBRID/tmp /home/cubrid/CUBRID/var/CUBRID_SOCK

COPY cubrid.sh /home/cubrid/

RUN echo '' >> /home/cubrid/.bash_profile; \
    echo 'export LANG=ko_KR.utf8' >> /home/cubrid/.bash_profile; \
    echo '' >> /home/cubrid/.bash_profile; \
    echo 'umask 077' >> /home/cubrid/.bash_profile; \
    echo '' >> /home/cubrid/.bash_profile; \
    echo '. /home/cubrid/cubrid.sh' >> /home/cubrid/.bash_profile; \
    chown -R cubrid:cubrid /home/cubrid

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh; \
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

VOLUME /home/cubrid/CUBRID/databases

EXPOSE 22 1523 8001 30000 33000

ENTRYPOINT ["docker-entrypoint.sh"]
