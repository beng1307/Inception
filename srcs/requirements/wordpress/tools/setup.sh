#!/bin/bash

# WordPress installieren (falls noch nicht da)
if [ ! -f /var/www/html/wp-config.php ]; then

    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    sed -i "s/database_name_here/$DATABASE/" /var/www/html/wp-config.php
    sed -i "s/username_here/$USER/" /var/www/html/wp-config.php
    sed -i "s/password_here/$PASSWORD/" /var/www/html/wp-config.php
    sed -i "s/localhost/$MARIADB_PORT/" /var/www/html/wp-config.php
fi

# PHP-FPM starten
mkdir -p /run/php
PHP_FPM_BIN="$(command -v php-fpm || true)"

if [ -z "$PHP_FPM_BIN" ]; then
    PHP_FPM_BIN="$(ls /usr/sbin/php-fpm* 2>/dev/null | head -n 1)"
fi

if [ -z "$PHP_FPM_BIN" ]; then
    echo "Error: no php-fpm binary found"
    exit 1
fi

exec "$PHP_FPM_BIN" -F