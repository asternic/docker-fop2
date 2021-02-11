FROM debian:10
LABEL maintainer="Nicolas Gudiño <ngudino@asternic.net> AND Federico Pereira <fpereira@iperfex.com>"

ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    APACHE_RUN_DIR=/var/run/apache2

ENV MYSQL_HOST=localhost \
    MYSQL_DATABASE_FOP2=fop2 \
    MYSQL_USER=fop2 \
    MYSQL_PASSWORD=fop2 \
    FOP2_WEB_DBDIR=/var/lib/fop2/

ENV MSMTP='false'
ENV HTACCESS='false'

#ADD https://www.fop2.com/download/debian64 /usr/src/fop2.tarz
ADD http://download.fop2.com/fop2-2.31.30-debian-x86_64.tgz  /usr/src/fop2.tarz

RUN apt -y update \
    && apt -y install procps make net-tools curl vim default-mysql-client unzip msmtp \
    && apt -y install php php-cli php-common php-dev php-pear libmcrypt-dev \
    && php -v && php -m \
    && apt -y install php-cli php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN pecl install mcrypt

RUN echo "[mail function]" > /etc/php/7.3/mods-available/msmtprc.ini \
    && echo "sendmail_path = \"/usr/bin/msmtp -t\"" >> /etc/php/7.3/mods-available/msmtprc.ini

#COPY additionals/etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/
#COPY additionals/etc/httpd/conf.d/fop2.conf /etc/httpd/conf.d/
#COPY additionals/etc/httpd/conf.d/fop2-htaccess.conf /etc/httpd/conf.d/
#COPY additionals/etc/php.d/fop2.ini /etc/httpd/conf.d/
COPY additionals/etc/php.d/fop2.ini /etc/php/7.3/mods-available/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /usr/src

RUN tar -xzf /usr/src/fop2.tarz \
    && cd /usr/src/fop2 && make install \
    && cp -fra /usr/src/fop2/html/config.docker.php /var/www/html/fop2/config.php \
    && cp -fra /usr/src/fop2/html/admin/config.docker.php /var/www/html/fop2/admin/config.php \
    && cp -fra /usr/src/fop2/html/admin/functions-custom-dist.php /var/www/html/fop2/admin/functions-custom.php \
    && chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && rm -fr /usr/src/fop2 /usr/src/fop2.tarz

WORKDIR /var/www/html/fop2

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
