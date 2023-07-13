#!/bin/bash

set +e

[[ -e /app/config/local_define.php ]] || cp /app/local_define.php /app/config/local_define.php
[[ -e /app/data/files ]] || install -m 0755 -o www-data -g www-data -d /app/data/files
for dirname in _cache _cron _dumps _graphs _inventories _locales _lock _log _pictures _plugins _rss _sessions _tmp _uploads; do
	[[ -e /app/data/files/$dirname ]] || install -m 0755 -o www-data -g www-data -d /app/data/files/$dirname
done

if [[ -e /app/data/.db-installed ]]; then
	echo "DB already installed"
else
	cd /app/glpi && \
		echo "Running db:install" && \
		php bin/console db:install --db-host=$MYSQL_HOST --db-name=$MYSQL_DATABASE --db-user=$MYSQL_USER --db-password=$MYSQL_PASSWORD --no-interaction && \
		touch /app/data/.db-installed
fi

if [[ -e /app/data/.fusion-installed ]]; then
	echo "FusionInventory already installed"
else
	cd /app/glpi && \
		echo "Running plugin installation" && \
		php bin/console glpi:plugin:install --username=glpi fusioninventory && \
		php bin/console glpi:plugin:activate fusioninventory && \
		touch /app/data/.fusion-installed
fi

#Start cron service
service cron start

#Run apache in foreground mode.
/usr/sbin/apache2ctl -D FOREGROUND
