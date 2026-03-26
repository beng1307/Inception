FROM debian:latest

# Installs necessary packages

# The php package is the main PHP interpreter, which is required to run PHP scripts.

# The php-fpm package is used to run the PHP FastCGI Process Manager, which is necessary 
# for serving PHP applications like WordPress.

# php-mysql is the PHP extension that allows PHP to communicate with MySQL databases, 
# which is essential for WordPress to function properly.

# curl lets you install something from the internet, in this case,
# we will use it to download WordPress from the official website.
RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql curl \
    && rm -rf /var/lib/apt/lists/*


# We install WORDPRESS in the /var/www/html directory, 
# which is the default document root for many web servers.
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && mkdir -p /var/www/html \
    && cp -r wordpress/. /var/www/html/ \
    && PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') \
    && mkdir -p /etc/php/${PHP_VER}/fpm/pool.d \
    && rm -rf wordpress latest.tar.gz


# We copy the custom configuration file for PHP-FPM into the container.
COPY conf/www.conf /tmp/www.conf

RUN PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') \
    && cp /tmp/www.conf /etc/php/${PHP_VER}/fpm/pool.d/www.conf \
    && rm -f /tmp/www.conf


# Copy the setup file into the container
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh


# Executes the setup script
CMD ["/setup.sh"]