#Starts from debian
FROM debian:latest


# Install mariadb-server
RUN apt-get update && apt-get install -y mariadb-server


# It copies the custom configuration file for MariaDB into the container.
COPY conf/config.cnf /etc/mysql/mariadb.conf.d/


# It copies the init into the container and makes it executable
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh


# It starts the init file when the container is run
CMD ["/init.sh"]