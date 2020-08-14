FROM php:5.6-apache-stretch

MAINTAINER Joo Youngjin <youngjinj@cubrid.com>

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
        locales \
        iputils-ping \
        net-tools \
        openssh-client \
        openssh-server \
        openssl \
        sudo \
        unzip \
        vim \
        vsftpd \
    # Package for installing gd extension in php
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libgd3 \
        libgd-dev \
    # Package for building cubrid php driver
        libncurses5-dev \
    # Package for installing certbot
        certbot \
        python-certbot-apache \
    && apt-get clean

RUN localedef -f UTF-8 -i ko_KR ko_KR.utf8 \
    && ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

ENV LC_ALL ko_KR.utf8
ENV LANG ko_KR.utf8
ENV LANGUAGE ko_KR.utf8

RUN bash -c "echo -e '\nexport LC_ALL=ko_KR.utf8\nexport LANG=ko_KR.utf8\nexport LANGUAGE=ko_KR.utf8' >> /etc/profile" \
    && tail /etc/profile

ENV APACHE_RUN_USER cubridw
ENV APACHE_RUN_GROUP cubridw

RUN useradd -u 10000 -k /etc/skel -m -s /bin/bash cubridw \
    && echo "cubridw:password" | chpasswd \
    && usermod -aG sudo cubridw \
    && ln -s /var/www/html /home/cubridw/html

RUN curl -fsSL 'http://ftp.cubrid.org/CUBRID_Drivers/PHP_Driver/10.2.0/Linux/CUBRID-PHP-10.2.0.0003.tar.gz' \
        -o /home/cubridw/CUBRID-PHP-10.2.0.0003.tar.gz \
    && mkdir -p /home/cubridw/cubrid-php \
#   && tar -zxf /home/cubridw/CUBRID-PHP-10.2.0.0003.tar.gz -C /home/cubridw/cubrid-php --strip-components=1 \
    && tar -zxf /home/cubridw/CUBRID-PHP-10.2.0.0003.tar.gz -C /home/cubridw/cubrid-php \
    && ( \
            cd /home/cubridw/cubrid-php \
            && phpize \
            && ./configure \
            && make \
            && make install \
        ) \
    && docker-php-ext-enable cubrid

RUN docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir \
        --with-jpeg-dir \
        --with-png-dir \
        --with-webp-dir \
        --with-xpm-dir \
        --with-zlib-dir \
        --enable-gd-native-ttf \
    && docker-php-ext-install gd

RUN a2enmod expires \
    && a2enmod headers \
    && a2enmod proxy \
    && a2enmod proxy_http \
    && a2enmod rewrite \
    && a2enmod ssl

RUN cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/cubrid-extensions.conf
RUN a2dissite 000-default
RUN a2ensite cubrid-extensions

RUN cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/cubrid-extensions-ssl.conf
RUN a2ensite cubrid-extensions-ssl

RUN bash -c "echo -e '\n<IfModule mod_ssl.c>\n\tListen 443\n</IfModule>' >> /etc/apache2/ports.conf"

#     # Create a Self-Signed Certificate
# RUN mkdir -p /etc/apache2/ssl \
#     &&openssl req -new \
#         -newkey rsa:2048 -nodes -keyout /etc/apache2/ssl/cubrid.key \
#         -x509 -days 365 -out /etc/apache2/ssl/cubrid.crt \
#         -subj "/C=KR/ST=Seoul/L=Gangnam-gu/O=CUBRID Co., Ltd/CN=cubrid.extensions" \
#     # Check a certificate, expiration date and who signed it
#     && openssl x509 -in /etc/apache2/ssl/cubrid.crt -text -noout

RUN sed 's/\ \ set mouse=a/"\ \ set mouse=a/' -i /usr/share/vim/vim80/defaults.vim

RUN sed s/listen=NO/listen=YES/ -i /etc/vsftpd.conf \
    && sed s/listen_ipv6=YES/listen_ipv6=NO/ -i /etc/vsftpd.conf \
    && sed s/#write_enable=YES/write_enable=YES/ -i /etc/vsftpd.conf

RUN curl -fsSL 'https://raw.githubusercontent.com/ccampbell/chromephp/master/ChromePhp.php' \
        -o /usr/local/lib/php/ChromePhp.php

RUN chown -R cubridw:cubridw /home/cubridw/html \
    && chown -R cubridw:cubridw /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

WORKDIR /var/www/html

EXPOSE 21 80 443

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
