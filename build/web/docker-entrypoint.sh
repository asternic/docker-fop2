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

#true
cat > /etc/apache2/sites-available/fop2-htaccess.conf <<ENDLINE
<Directory "/var/www/html/fop2">
    AuthType Basic
    AuthName "Restricted Content"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Directory>
ENDLINE

cp -fra /etc/apache2/sites-available/fop2-htaccess.conf /etc/apache2/sites-enabled/fop2-htaccess.conf
/usr/bin/htpasswd -bc /etc/apache2/.htpasswd ${HTPASSWD_USER} ${HTPASSWD_PASS}
chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /etc/apache2/.htpasswd
chmod 0660 /etc/apache2/.htpasswd

else

#false
rm -fr /etc/apache2/sites-available/fop2-htaccess.conf
rm -fr /etc/apache2/sites-enabled/fop2-htaccess.conf
rm -fr /etc/apache2/.htpasswd

fi

chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} -R /var/www/html/fop2

exec "$@"
