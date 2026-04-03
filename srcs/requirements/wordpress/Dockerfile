#Starts from debian
FROM debian:latest


# Installs PHP, PHP-FPM, the MySQL extension for PHP, curl, and the MariaDB client
RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*


# Installs WordPress CLI which lets you use WordPress with commands instead of interface
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp


# Installs Wordpress
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && mkdir -p /usr/src/wordpress \
    && cp -r wordpress/. /usr/src/wordpress/ \
    && PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') \
    && mkdir -p /etc/php/${PHP_VER}/fpm/pool.d \
    && rm -rf wordpress latest.tar.gz


# Copies the configs into the container
COPY conf/www.conf /tmp/www.conf


# Finds the PHP version and copies the configuration to the right location
RUN PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') \
    && cp /tmp/www.conf /etc/php/${PHP_VER}/fpm/pool.d/www.conf \
    && rm -f /tmp/www.conf


# Copies the setup file into the container
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh


# Executes the setup script
CMD ["/setup.sh"]