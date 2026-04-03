#!/bin/bash

# Activates errors
set -e


# Creates the necessary directories for SSL certificates
mkdir -p /etc/nginx/ssl


# Checks for Certificates and creates them if they don't exist
if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then

	# Batch deactivates questions and config is
	# for a default answer to create a self signed-certificate
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-batch \
		-config /etc/ssl/openssl.cnf

fi


exec nginx -g "daemon off;"
