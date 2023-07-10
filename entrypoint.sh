#!/bin/bash
if [[ -e /app/data/.db-installed ]]; then
	echo "DB already installed"
else
	cd /app/glpi && \
		php bin/console db:install --db-host=$MYSQL_HOST --db-name=$MYSQL_DATABASE --db-user=$MYSQL_USER --db-password=$MYSQL_PASSWORD --no-interaction && \
		touch /app/data/.db-installed
fi

#Start cron service
service cron start

#Run apache in foreground mode.
/usr/sbin/apache2ctl -D FOREGROUND
