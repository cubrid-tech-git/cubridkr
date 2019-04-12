FROM php:5.6-apache-stretch

MAINTAINER Joo Youngjin <youngjinj@cubrid.com>

RUN apt-get update -y \
    ; apt-get install -y vim \
                         openssh-server \
                         openssh-client \
                         locales \
    ; apt-get clean

RUN localedef -f UTF-8 -i ko_KR ko_KR.utf8 \
    ; ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

ENV LC_ALL ko_KR.utf8
ENV LANG ko_KR.utf8
ENV LANGUAGE ko_KR.utf8

RUN curl -fsSL 'http://ftp.cubrid.org/CUBRID_Drivers/PHP_Driver/9.3.0/Linux/CUBRID-PHP5-9.3.0.0001.src.tar.gz' \
        -o /root/CUBRID-PHP5-9.3.0.0001.src.tar.gz \
    && mkdir -p /tmp/cubrid \
    && tar -zxf /root/CUBRID-PHP5-9.3.0.0001.src.tar.gz -C /tmp/cubrid --strip-components=1 \
    && ( \
        cd /tmp/cubrid \
        && phpize \
        && ./configure --enable-cubrid \
        && make -j "$(nproc)" \
        && make install \
    ) \
    && rm -r /tmp/cubrid \
    && docker-php-ext-enable cubrid

RUN a2enmod rewrite
RUN a2enmod headers

RUN useradd -g www-data -k /etc/skel -m -s /bin/bash www \
    && ln -sf /var/www/html /home/www/html \ 
    && chown -R www:www-data /var/www/html

RUN curl -fsSL 'https://raw.githubusercontent.com/ccampbell/chromephp/master/ChromePhp.php' \
        -o /usr/local/lib/php/ChromePhp.php

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    ; ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

WORKDIR /var/www/html

EXPOSE 22 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
