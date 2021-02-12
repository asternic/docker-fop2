FROM debian:10
LABEL maintainer="Nicolas Gudiño <ngudino@asternic.net> AND Federico Pereira <fpereira@iperfex.com>"
LABEL description="Flash Operator Panel 2"
LABEL url="https://www.fop2.com"
LABEL github="https://github.com/asternic/docker-fop2"

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
ENV TIMEZONE='America/Argentina/Buenos_Aires'
ENV TZ=$TIMEZONE
ENV DEBIAN_FRONTEND=noninteractive

#ADD https://www.fop2.com/download/debian64 /usr/src/fop2.tarz
ADD http://download.fop2.com/fop2-2.31.30-debian-x86_64.tgz  /usr/src/fop2.tarz

RUN apt -y update \
    && apt -y install procps make net-tools curl vim default-mysql-client unzip msmtp tzdata \
    && apt -y install php php-cli php-common php-dev php-pear libmcrypt-dev \
    && apt -y install php-cli php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-sqlite3\
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN pecl install mcrypt

RUN echo "[mail function]" > /etc/php/7.3/mods-available/msmtprc.ini \
    && echo "sendmail_path = \"/usr/bin/msmtp -t\"" >> /etc/php/7.3/mods-available/msmtprc.ini

WORKDIR /usr/src

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN tar -xzf /usr/src/fop2.tarz \
    && cd /usr/src/fop2 && make install \
    && cp -fra /usr/src/fop2/html/config.docker.php /var/www/html/fop2/config.php \
    && cp -fra /usr/src/fop2/html/admin/config.docker.php /var/www/html/fop2/admin/config.php \
    && cp -fra /usr/src/fop2/html/admin/functions-custom-dist.php /var/www/html/fop2/admin/functions-custom.php \
    && chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && rm -fr /usr/src/fop2 /usr/src/fop2.tarz

RUN a2enmod ssl && a2enmod rewrite && a2dissite 000-default.conf default-ssl.conf \
    && rm -rf /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/default-ssl.conf \
    && sed -i 's/^ServerSignature/#ServerSignature/g' /etc/apache2/conf-enabled/security.conf \
    && sed -i 's/^ServerTokens/#ServerTokens/g' /etc/apache2/conf-enabled/security.conf \
    && echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf \
    && echo "ServerTokens Prod" >> /etc/apache2/conf-enabled/security.conf

COPY additionals/etc/apache2/sites-available/*.conf /etc/apache2/sites-available/
COPY additionals/etc/apache2/sites-available/*.conf /etc/apache2/sites-enabled/
COPY additionals/etc/apache2/options-ssl-apache.conf /etc/apache2/options-ssl-apache.conf
COPY additionals/etc/php.d/fop2.ini /etc/php/7.3/mods-available/

WORKDIR /var/www/html/fop2

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
