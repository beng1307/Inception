#Starts from debian
FROM debian:latest


# Installs nginx and openssl
RUN apt-get update && apt-get install -y nginx openssl \
	&& rm -rf /var/lib/apt/lists/*


# It copies the configs into the container
COPY conf/default.conf /etc/nginx/conf.d/default.conf


# It copies the script into the container and makes it executable
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh


# Executes the script
CMD ["/setup.sh"]
