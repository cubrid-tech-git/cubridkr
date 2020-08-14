#!/bin/bash

# Disable exitting on error
set +e

service ssh start
service vsftpd start

chown -R cubridw:cubridw /var/www/html

find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Test "renew" or "certonly" without saving any certificates to disk
# certbot certonly --webroot -w /var/www/html -d cubrid.extensions --dry-run

# certbot certonly --webroot -w /var/www/html -d cubrid.extensions certonly
# certbot certonly --webroot -w /var/www/html -d cubrid.extensions

docker-php-entrypoint $@
