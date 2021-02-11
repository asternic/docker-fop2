#!/bin/bash
set -e

echo "FOP2 - AUTOCONFIGURE"

if [ ! -f /etc/php/7.3/mods-available/timezone.ini ]; then
          echo "date.timezone = $TIMEZONE" > /etc/php/7.3/mods-available/timezone.ini
fi

if [ $MSMTP = "true" ]; then

        cat > /etc/msmtprc <<ENDLINE
defaults
auth           ${MSMTP_AUTH}
tls            ${MSMTP_TTS}
tls_trust_file ${MSMTP_TTS_TRUST_FILE}
syslog         ${MSMTP_SYSLOG}

account        $MSMTP_ACCOUNT
host           ${MSMTP_HOST}
auth           ${MSMTP_ACCOUNT_AUTH}
port           ${MSMTP_PORT}
from           ${MSMTP_FROM}
user           ${MSMTP_USER}
password       ${MSMTP_PASSWORD}

# Set a default account
account default : $MSMTP_ACCOUNT
aliases        /etc/aliases
ENDLINE

fi


if [ $HTACCESS = "true" ]; then

        if [ ! -f /var/www/html/fop2/.htaccess ]; then
                cat > /var/www/html/fop2/.htaccess <<ENDLINE
AddDefaultCharset UTF-8
php_value magic_quotes_gpc off
<Files *>
Header set Cache-Control: "private, pre-check=0, post-check=0, max-age=0"
Header set Expires: 0
Header set Pragma: no-cache
</Files>

AuthType Basic
AuthName "Restricted Content"
AuthUserFile /htpasswd/.htpasswd
Require valid-user
ENDLINE

                /usr/bin/htpasswd -bc /htpasswd/.htpasswd ${HTPASSWD_USER} ${HTPASSWD_PASS}
                chown apache:apache /htpasswd/.htpasswd
                chmod 0660 /htpasswd/.htpasswd
        fi

fi

chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} -R /var/www/html/fop2

exec "$@"
