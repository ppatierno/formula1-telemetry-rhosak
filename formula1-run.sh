#!/usr/bin/env bash

# $1 env file with service account credentials
# $2 RHOSAK bootstrap servers
# $3 path to the application jar

# to generate via the rhoas service-account create --short-description formaula1-udp-kafka --file-format env --output-file ./formula1-udp-kafka.env
source $1

export KAFKA_TLS_ENABLED=true
export KAFKA_BOOTSTRAP_SERVERS=$2
export KAFKA_SASL_MECHANISM=PLAIN
export KAFKA_SASL_USERNAME=${RHOAS_SERVICE_ACCOUNT_CLIENT_ID}
export KAFKA_SASL_PASSWORD=${RHOAS_SERVICE_ACCOUNT_CLIENT_SECRET}

echo "Formula1 script configuration:"
echo "- KAFKA_TLS_ENABLED=${KAFKA_TLS_ENABLED}"
echo "- KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS}"
echo "- KAFKA_SASL_MECHANISM=${KAFKA_SASL_MECHANISM}"
echo "- KAFKA_SASL_USERNAME=${KAFKA_SASL_USERNAME}"
echo "- KAFKA_SASL_PASSWORD=${KAFKA_SASL_PASSWORD}"

java -jar $3
