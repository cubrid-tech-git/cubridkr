FROM centos/systemd

MAINTAINER Joo Youngjin <youngjinj@cubrid.com>

RUN yum update -y \
    && yum install -y epel-release \
    && yum install -y openssh-clients \
                      openssh-server \
                      sudo \
    && yum install -y net-tools \
                      vim-enhanced \
                      wget \
                      which \
    && yum install -y telnet \
                      expect \
    && yum install -y java-1.8.0-openjdk-devel \
    && yum install -y cockpit \
                      cockpit-dashboard \
    && yum clean all

RUN localedef -f UTF-8 -i ko_KR ko_KR.utf8 \
    && ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

ENV LC_ALL ko_KR.utf8
ENV LANG ko_KR.utf8
ENV LANGUAGE ko_KR.utf8

RUN touch /etc/sysconfig/network

RUN systemctl disable NetworkManager
RUN systemctl enable sshd
RUN systemctl enable cockpit.socket

RUN echo 'root:password' | chpasswd

CMD ["/usr/sbin/init"]
