#!/bin/bash

# Update and upgrade the system
yum update
yum upgrade -y

# Install httpd and OpenSSL
yum install httpd mod_ssl openssl -y

# Create a self-signed SSL certificate
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/pki/tls/private/apache-selfsigned.key -out /etc/pki/tls/certs/apache-selfsigned.crt -subj "/C=US/ST=California/L=Los Angeles/O=IT/CN=example.com"

# Configure httpd with the SSL certificate
cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig
sed -i 's/SSLCertificateFile \/etc\/pki\/tls\/certs\/localhost.crt/SSLCertificateFile \/etc\/pki\/tls\/certs\/apache-selfsigned.crt/g' /etc/httpd/conf.d/ssl.conf
sed -i 's/SSLCertificateKeyFile \/etc\/pki\/tls\/private\/localhost.key/SSLCertificateKeyFile \/etc\/pki\/tls\/private\/apache-selfsigned.key/g' /etc/httpd/conf.d/ssl.conf

# Restart httpd
systemctl restart httpd

# Create the default page
echo "<html><body><h1>You're an idiot</h1></body></html>" > /var/www/html/index.html
