# kafka-poc
Azure MS SQL > Kafka (on an Azure VM with docker) > Azure Blob

# PREREQUISITES

1. Create Azure VM with Oracle Linux
https://www.youtube.com/watch?v=qemJWVPg4Z4
VM user name: azureuser

2. Configure putty with ssh
https://www.youtube.com/watch?v=8Wjs-ZYfDN0
putty > SSH > Auth > Credentials > "Private key file for authentication"

3. Install Docker on the VM
https://sergiodelamo.com/blog/2024-09-06-oracle-cloud-linux-9-enable-docker.html

4. Linux post-installation steps for Docker Engine
https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
4.1. Create docker group:
sudo groupadd docker
4.2. Add user to docker group:
sudo usermod -aG docker $USER
4.3. Activate changes without logout/login
newgrp docker
4.4. Test:
docker run hello-world
4.5. Configure Docker to start on boot with systemd
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

5. Create Azure SQL db
https://www.youtube.com/watch?v=6joGkZMVX4o
NOTE: SQL server host name and database name should NOT contain "-" in the name.

6. Create Azure storage account:
https://learn.microsoft.com/en-gb/azure/storage/common/storage-account-create?tabs=azure-portal
Manage storage account access keys:
https://learn.microsoft.com/en-us/azure/storage/common/storage-account-keys-manage?tabs=azure-portal


# KAFKA Install with Docker image

1. Install Kafka
1.1. Download the contents of the Docker Compose file:
curl --silent --output docker-compose.yml https://raw.githubusercontent.com/albenakoteva/kafka-poc/refs/heads/main/docker-compose.yml
1.3. Start Confluent Platform:
NOTE: Replace the "-" with a space in docker-compose command: use "docker compose" instead of "docker-compose" (https://kodekloud.com/blog/docker-compose-command-not-found/)
docker compose up -d
1.3. Verify that the services are up and running:
docker compose ps
1.4. Start/Stop the Docker containers for Confluent:
docker compose start
docker compose stop
1.5. Clean up Confluent containers, networks, volumes and images:
docker system prune -a --volumes --filter "label=io.confluent.docker"

## 2. Create Connectors
2.1. Create environment variables for sensitive data:
export AZ_BLOB_ACCOUNT_NAME="<your-azure-account>"
export AZ_BLOB_ACCOUNT_KEY="<your-key>"
export MSSQL_DB_HOST="<host_name>"
export MSSQL_DB_NAME="<db_name>"
export MSSQL_DB_USER="<user>"
export MSSQL_DB_PASS="<pass>"

2.2. Create source connector
2.2.1. AVRO flatten messages with schema, list of tables:
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    --data-binary @<(curl -sL https://raw.githubusercontent.com/albenakoteva/kafka-poc/main/config/source_connector_avro_messages_flatten.json | envsubst) \
    localhost:8083/connectors
	
2.2.2. JSON flatten messages with schema, list of tables:
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    --data-binary @<(curl -sL https://raw.githubusercontent.com/albenakoteva/kafka-poc/main/config/source_connector_json_messages_flatten.json | envsubst) \
    localhost:8083/connectors

2.2.3. AVRO default Dezerium messages structure, all non system tables:
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    --data-binary @<(curl -sL https://raw.githubusercontent.com/albenakoteva/kafka-poc/main/config/source_connector_avro_messages_default.json | envsubst) \
    localhost:8083/connectors

JSON default Dezerium messages structure with schema, list of tables:
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    --data-binary @<(curl -sL https://raw.githubusercontent.com/albenakoteva/kafka-poc/main/config/source_connector_json_messages_default.json | envsubst) \
    localhost:8083/connectors

2.3. Create sink connector
NOTE:
1.
The configuration property "confluent.topic.bootstrap.servers" should be set to "broker:29092", not to "localhost:9092"
"confluent.topic.bootstrap.servers": "broker:29092"
2.
To create a different blob objects for each db record:
The connector’s flush.size configuration property specifies the maximum number of records that should be written to a single Azure Blob Storage object.
"flush.size": "1"
3. 
The default value of "behavior.on.null.values" is "fail". In that case when a null message is submitted, e.g. if a record is deleted, the connector fails.
If the connector should not fail on record deletion, use the following configuration:
"behavior.on.null.values": "ignore"

2.3.1. Time partitioner:
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    --data-binary @<(curl -sL https://raw.githubusercontent.com/albenakoteva/kafka-poc/refs/heads/main/config/sink_connector_time_partitioner.json | envsubst) \
    localhost:8083/connectors

NOTE: 
1. 
To use time partitioning you need to flatten the message structure, e.g. use the topics created by "source_connector_avro_messages_flatten.json" or "source_connector_json_messages_flatten.json".
2.
When the time.precision.mode configuration property is set to connect, then the connector will use the predefined Kafka Connect logical types ("time.precision.mode": "connect"). 
Otherwise it converts DATETIME2 to a io.debezium.time.NanoTimestamp and this cannot be correctly interpreted by the consumer.


2.3.2. Field partitioner:
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    --data-binary @<(curl -sL https://raw.githubusercontent.com/albenakoteva/kafka-poc/refs/heads/main/config/sink_connector_field_partitioner.json | envsubst) \
    localhost:8083/connectors

NOTE: 
1.
To use field partitioning you need to flatten the message structure, e.g. use the topics created by "source_connector_avro_messages_flatten.json" or "source_connector_json_messages_flatten.json".

2.3.3. Multiple fields partitioner (2):
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    --data-binary @<(curl -sL https://raw.githubusercontent.com/albenakoteva/kafka-poc/refs/heads/main/config/sink_connector_2fields_partitioner.json | envsubst) \
    localhost:8083/connectors

NOTE: 
1.
To use field partitioning you need to flatten the message structure, e.g. use the topics created by "source_connector_avro_messages_flatten.json" or "source_connector_json_messages_flatten.json".


2.3.4. Default partitioner:
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
    --data-binary @<(curl -sL https://raw.githubusercontent.com/albenakoteva/kafka-poc/refs/heads/main/config/sink_connector_default_partitioner.json | envsubst) \
    localhost:8083/connectors

2.3.5. Mixed partitioner (field + time)
Hint: Consider partitioning across topics on source connector level


# Commands:

## List the connector plugins available on a worker:
curl localhost:8083/connector-plugins | jq

## Check the status of the connectors
# Apache Kafka >=2.3
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
       jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
       column -s : -t| sed 's/\"//g'| sort

## List topics
docker exec broker kafka-topics --list --bootstrap-server localhost:9092 

## Delete topics
docker exec broker kafka-topics --delete --topic mssql-source --bootstrap-server localhost:9092 

## Check Kafka connect log:
docker compose logs -f kafka-connect

## Check single connector status
curl -s http://localhost:8083/source-mssql-avro-flatten/status | jq

## delete connector
curl -X DELETE http://localhost:8083/connectors/source-mssql-avro-flatten

## Connect to kafka container to execute commands
docker container exec -it broker /bin/bash
## Check messages in a topic (from within kafka container /bin/bash)
kafka-console-consumer --bootstrap-server localhost:9092 --topic mssql-source.sqldb.dbo.customers -from-beginning

kafka-console-consumer --bootstrap-server localhost:9092 --topic mssql-source.sqldb.dbo.customers -from-beginning --property print.key=true --property key.separator=":"  --no-wait-at-logend

kafka-console-consumer --bootstrap-server localhost:9092 --topic source-mssql-1table.sqldb.dbo.customers --from-beginning --property print.key=true --property print.value=true

kafka-console-consumer --bootstrap-server localhost:9092 \
--topic source-mssql-1table4.sqldb.dbo.customers \
--from-beginning \
--property print.key=true \
--property print.value=true \
--formatter org.apache.kafka.tools.consumer.DefaultMessageFormatter \
--property value.deserializer=org.apache.kafka.common.serialization.StringDeserializer


# Related documentation and examples:
Quick Start for Confluent Platform - Community Components (Docker):
https://docs.confluent.io/platform/current/get-started/platform-quickstart.html

Debezium source connector from SQL Server to Apache Kafka (FREE)
https://debezium.io/documentation/reference/stable/connectors/sqlserver.html
https://medium.com/@kayvan.sol2/debezium-source-connector-from-sql-server-to-apache-kafka-7d59d56f5cc7
New Record State Extraction - flatten message structure:
https://debezium.io/documentation/reference/stable/transformations/event-flattening.html

Azure Blob Storage Sink Connector for Confluent Platform (30 days trial)
https://docs.confluent.io/kafka-connectors/azure-blob-storage-sink/current/overview.html

vi editor commands:
https://www.redhat.com/en/blog/introduction-vi-editor

Apache Kafka get started:
https://www.youtube.com/playlist?list=PLa7VYi0yPIH0KbnJQcMv5N9iW8HkZHztH

Kafka connect:
https://developer.confluent.io/courses/kafka-connect/intro/

Set up Python for producers & consumers API:
https://www.youtube.com/watch?v=Aaf4Z0hAZe4&list=PLa7VYi0yPIH0KbnJQcMv5N9iW8HkZHztH&index=11

JSON formatter:
https://www.jsonformatter.io/