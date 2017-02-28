#!/bin/bash
# echo '"$POSTGRES_USER" "$POSTGRES_PASSWORD"' > /opt/pgbouncer/users.txt
cd /opt/pgbouncer
gosu postgres bin/pgbouncer config.ini
