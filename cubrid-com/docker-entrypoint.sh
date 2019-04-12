#!/bin/bash

if [[ ! -z "$USER_PASSWORD" ]]; then
    echo "www:$USER_PASSWORD" | chpasswd
elif [[ -z "$USER_PASSWORD" ]]; then
    echo "www:cubridp@ssw0rd" | chpasswd
fi

chown -R www:www-data /var/www/html

service ssh start \
; docker-php-entrypoint $@
