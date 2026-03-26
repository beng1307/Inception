#!/bin/bash

set -e

# MariaDB runtime directories must exist and be writable by mysql.
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -f "/var/lib/mysql/.inception_init_done" ]; then
	# Start temporary server for one-time SQL initialization.
	mysqld_safe --skip-networking &

	# Wait until local socket is ready.
	until mysqladmin ping --silent; do
		sleep 1
	done


	mysql -e "CREATE DATABASE IF NOT EXISTS ${DATABASE};"
	mysql -e "CREATE USER IF NOT EXISTS '${USER}'@'%' IDENTIFIED BY '${PASSWORD}';"
	mysql -e "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO '${USER}'@'%';"
	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';"
	mysql -e "FLUSH PRIVILEGES;"
	touch /var/lib/mysql/.inception_init_done

	# Stop temporary server cleanly, then launch final foreground process.
	if ! mysqladmin -uroot -p"${ROOT_PASSWORD}" shutdown; then
		mysqladmin shutdown
	fi
fi

exec mysqld_safe
