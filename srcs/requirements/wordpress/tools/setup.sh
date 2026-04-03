#!/bin/bash

# Activates errors
set -e


# Variables
WORDPRESS_PATH="/var/www/html"
WORDPRESS="wp --allow-root --path=${WORDPRESS_PATH}"
DB_PASSWORD="$(cat /run/secrets/db_password)"
ADMIN_PASSWORD="$(grep 'WP_ADMIN_PASSWORD' /run/secrets/credentials | cut -d '=' -f2)"
USER_PASSWORD="$(grep 'WP_USER_PASSWORD' /run/secrets/credentials | cut -d '=' -f2)"


# Copies the WordPress files and sets the ownership
if [ ! -f $WORDPRESS_PATH/index.php ]; then

	cp -r /usr/src/wordpress/* $WORDPRESS_PATH/
	chown -R www-data:www-data $WORDPRESS_PATH/

fi


# Copies the config sample and changes the configs
if [ ! -f $WORDPRESS_PATH/wp-config.php ]; then

	cp /usr/src/wordpress/wp-config-sample.php $WORDPRESS_PATH/wp-config.php

	sed -i "s/database_name_here/${DATABASE}/" $WORDPRESS_PATH/wp-config.php
	sed -i "s/username_here/${DB_USER}/" $WORDPRESS_PATH/wp-config.php
	sed -i "s/password_here/${DB_PASSWORD}/" $WORDPRESS_PATH/wp-config.php
	sed -i "s/localhost/mariadb/" $WORDPRESS_PATH/wp-config.php

fi


# Waits for db to be ready before proceeding with installation
until $WORDPRESS db check >/dev/null 2>&1; do
	sleep 1
done


# Installs WordPress and creates the admin and user
if [ ! -f $WORDPRESS_PATH/.inception_init_done ]; then

	$WORDPRESS core install \
		--path=$WORDPRESS_PATH \
		--url=$WP_URL \
		--title=$WP_TITLE \
		--admin_user=$WP_ADMIN \
		--admin_password=$ADMIN_PASSWORD \
		--admin_email=$WP_ADMIN_EMAIL


	$WORDPRESS user create "$WP_USER" "$WP_USER_EMAIL" \
		--role=editor \
		--user_pass="$USER_PASSWORD"


	touch $WORDPRESS_PATH/.inception_init_done

fi


# Creates the directory php-fpm needs
mkdir -p /run/php


# Finds the php-fpm version and executes it
PHP_FPM="$(ls /usr/sbin/php-fpm* 2>/dev/null | head -n 1)"
exec "$PHP_FPM" -F