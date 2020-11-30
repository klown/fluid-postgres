#!/bin/sh

# Copyright 2020 OCAD University
#
# Licensed under the New BSD license. You may not use this file except in
# compliance with this License.
#
# You may obtain a copy of the License at
# https://github.com/GPII/universal/blob/master/LICENSE.txt

# Starts up a Postgres database using a docker image.  If it is not present, it 
# is downloaded (pulled) from dockerhub.
#
# Note the docker image is preset to use these ports:
# - 26257/tcp for accessing the database
# - 8080/tcp for the web-based admin viewer

# Default values
POSTGRES_MAIN_CONTAINER=${POSTGRES_MAIN_CONTAINER:-"postgresdb"}
POSTGRES_LISTEN_PORT=${POSTGRES_LISTEN_PORT:-5432}
POSTGRES_USER=${POSTGRES_USER:-"admin"}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"asecretpassword"}
POSTGRES_IMAGE=${POSTGRES_IMAGE:-"postgres:13.1-alpine"}

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "POSTGRES_MAIN_CONTAINER: $POSTGRES_MAIN_CONTAINER"
log "POSTGRES_LISTEN_PORT: $POSTGRES_LISTEN_PORT"
log "POSTGRES_USER: $POSTGRES_USER"
log "POSTGRES_IMAGE: $POSTGRES_IMAGE"

log "Starting postgres in a docker container ..."
docker run -d \
    --name="$POSTGRES_MAIN_CONTAINER" \
    -e POSTGRES_USER=$POSTGRES_USER \
    -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
    -p $POSTGRES_LISTEN_PORT:$POSTGRES_LISTEN_PORT \
    -d $POSTGRES_IMAGE postgres

log "Checking that PostgresDB is ready..."
POSTGRESDB_ISREADY=0
for i in `seq 1 30`
do
    docker exec --user postgres postgresdb pg_isready
    if [ $? = 0 ]; then
        POSTGRESDB_ISREADY=1
        break
    fi
    sleep 2 # seconds
done

if [ $POSTGRESDB_ISREADY = 1 ]; then
    echo "Creating 'fluid_prefsdb' database ..."
    docker exec "$POSTGRES_MAIN_CONTAINER" \
        createdb -U $POSTGRES_USER -p $POSTGRES_LISTEN_PORT -e fluid_prefsdb
else
    echo "Failed to start database server"
fi
