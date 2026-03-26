#!/bin/bash

set -e

# MariaDB runtime directories must exist and be writable by mysql.
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Start temporary server for idempotent SQL initialization.
mysqld_safe --skip-networking &

# Wait until local socket is ready.
until mysqladmin ping --silent; do
	sleep 1
done

if mysql -uroot -p"${ROOT_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; then
	MYSQL_AUTH=( -uroot -p"${ROOT_PASSWORD}" )
else
	MYSQL_AUTH=()
fi

mysql "${MYSQL_AUTH[@]}" -e "CREATE DATABASE IF NOT EXISTS ${DATABASE};"
mysql "${MYSQL_AUTH[@]}" -e "CREATE USER IF NOT EXISTS '${USER}'@'%' IDENTIFIED BY '${PASSWORD}';"
mysql "${MYSQL_AUTH[@]}" -e "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO '${USER}'@'%';"
mysql "${MYSQL_AUTH[@]}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';"
mysql -uroot -p"${ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Stop temporary server cleanly, then launch final foreground process.
mysqladmin -uroot -p"${ROOT_PASSWORD}" shutdown

exec mysqld_safe
