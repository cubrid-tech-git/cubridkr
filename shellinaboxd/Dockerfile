FROM centos:7

MAINTAINER Joo Youngjin <youngjinj@cubrid.com>

RUN yum update -y \
    ; yum install -y epel-release \
    ; yum install -y sudo \
                     openssl \
                     shellinabox \
    ; yum clean all

RUN localedef -f UTF-8 -i ko_KR ko_KR.utf8 \
    ; ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

ENV LC_ALL ko_KR.utf8
ENV LANG ko_KR.utf8
ENV LANGUAGE ko_KR.utf8

RUN useradd centos \
    && echo 'centos:password' | chpasswd \
    && sed 102s/#\ %wheel/%wheel/ -i /etc/sudoers \
    && sed s/wheel:x:10:/wheel:x:10:centos/ -i /etc/group

EXPOSE 4200

ENTRYPOINT ["shellinaboxd", "-t", "-s", "/:LOGIN"]
