#!/bin/bash
set -euo pipefail

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

# Initialize MariaDB data directory on first start
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

echo "Starting MariaDB..."
mysqld --user=mysql --datadir=/var/lib/mysql &
MARIADB_PID=$!

# Wait for MariaDB to become ready
for i in $(seq 1 30); do
    if mysqladmin ping --silent >/dev/null 2>&1; then
        echo "MariaDB ready"
        break
    fi
    if ! kill -0 "$MARIADB_PID" 2>/dev/null; then
        echo "MariaDB failed to start" >&2
        exit 1
    fi
    if [ "$i" -eq 30 ]; then
        echo "MariaDB did not become ready in time" >&2
        exit 1
    fi
    sleep 1
done

echo "Starting Tomcat..."
exec /usr/share/tomcat10/bin/catalina.sh run
