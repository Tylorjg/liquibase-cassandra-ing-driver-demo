#!/bin/bash

LIQUIBASE_VERSION=4.25.1
ING_DRIVER_VERSION=4.11.1
CONTAINER_NAME=liquibase-cassandra-ING-demo
DB_USERNAME=
DB_PASSWORD=
DB_DEFAULT_KEYSPACE=movies
DB_EXPOSED_PORT=9045

# Create the docker cassandra database
docker run --name $CONTAINER_NAME -p $DB_EXPOSED_PORT:9042 -e CASSANDRA_USER=$DB_USERNAME -e CASSANDRA_PASSWORD=$DB_PASSWORD -d cassandra:latest

# Wait for Cassandra to be ready
until docker exec -it $CONTAINER_NAME nodetool status | grep "Up" &> /dev/null; do
    echo "Waiting for Cassandra to be ready..."
    sleep 10
done

# Get the data center for the docker database. Found using the nodetool command.
DATACENTER=$(docker exec -it $CONTAINER_NAME nodetool status | grep 'Datacenter: ' | awk '{print $2}')

# Create a default keyspace to use and set in the liquibase.properties file
until docker exec $CONTAINER_NAME cqlsh -e "DESCRIBE KEYSPACES" | grep "$DB_DEFAULT_KEYSPACE" &> /dev/null; do
    echo "Attempting to create default keyspace for Cassandra..."
    docker exec -it $CONTAINER_NAME cqlsh -e "CREATE KEYSPACE IF NOT EXISTS $DB_DEFAULT_KEYSPACE WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};" > /dev/null 2>&1
    sleep 10
done

# Create liquibase.properties file with the information provided above. 
cat <<EOF > liquibase.properties
changeLogFile: mainChangelog.xml
url: jdbc:cassandra://localhost:$DB_EXPOSED_PORT/$DB_DEFAULT_KEYSPACE?localdatacenter=$DATACENTER&compliancemode=Liquibase
driver: com.ing.data.cassandra.jdbc.CassandraDriver
username: $DB_USERNAME
password: $DB_PASSWORD
liquibaseProLicenseKey:
EOF

curl -L https://github.com/liquibase/liquibase-cassandra/releases/download/untagged-267bb44cdeb2c2d645b1/liquibase-cassandra-$LIQUIBASE_VERSION.jar --output liquibase-cassandra-$LIQUIBASE_VERSION.jar

curl -L https://github.com/ing-bank/cassandra-jdbc-wrapper/releases/download/v4.11.1/cassandra-jdbc-wrapper-$ING_DRIVER_VERSION-bundle.jar --output cassandra-jdbc-wrapper-$ING_DRIVER_VERSION-bundle.jar

echo "Compelete"