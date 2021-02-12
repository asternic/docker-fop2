#!/bin/bash
set -e


if [ "$MYSQL_HOST" != '' ] && [ "$MYSQL_PORT" != '' ] && [ "$MYSQL_USER" != '' ] && [ "$MYSQL_PASSWORD" != '' ] && [ "$MYSQL_DATABASE_FOP2" != '' ] ;then

cat > /etc/amportal.conf <<ENDLINE
AMPDBUSER=${MYSQL_USER}
AMPDBPASS=${MYSQL_PASSWORD}
AMPDBNAME=${MYSQL_DATABASE_FOP2}
AMPDBHOST=${MYSQL_HOST}
AMPDBPORT=${MYSQL_PORT}
ENDLINE

fi

exec "$@"
