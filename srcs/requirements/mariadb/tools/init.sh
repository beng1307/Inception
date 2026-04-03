#!/bin/bash

# Activates errors
set -e


# Variables
DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"


# Creates the necessary directories and sets the ownership
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql


# Initializes the database
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi


# Starts a temporary server to create the database and user
if [ ! -f "/var/lib/mysql/.inception_init_done" ]; then

	#Starts the server without networking
	mysqld_safe --skip-networking &

	# Waits for the server to be ready
	until mysqladmin ping --silent; do
		sleep 1
	done

	# Creates the database and user, and grants privileges
	mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${DATABASE};"
	mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
	mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO '${DB_USER}'@'%';"
	mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
	mysql -uroot -p"${DB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

	# Shuts down the temporary server
	mysqladmin -uroot -p"${DB_ROOT_PASSWORD}" shutdown

	# Creates a file as a flag that it's initialized
	touch /var/lib/mysql/.inception_init_done
fi

# Starts the server
exec mysqld_safe
