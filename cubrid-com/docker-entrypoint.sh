#!/bin/bash

if [[ ! -z "$USER_PASSWORD" ]]; then
    echo "www:$USER_PASSWORD" | chpasswd
elif [[ -z "$USER_PASSWORD" ]]; then
    echo "www:cubridp@ssw0rd" | chpasswd
fi

chown -R www:www-data /var/www/html

sed s/#\ write_enable=YES/write_enable=YES/g -i i/etc/vsftpd.conf

service ssh start \
; service vsftpd start \
; docker-php-entrypoint $@
