# Formula 1 telemetry on Red Hat OpenShift Streams for Apache Kafka

This repository describes the way to deploy the [Formula 1 - Telemetry with Apache Kafka](https://github.com/ppatierno/formula1-telemetry-kafka) on a managed Kafka instance provided via the [Red Hat OpenShift Streams for Apache Kafka service](https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-streams-for-apache-kafka).

 ## Prerequisites

 The main pre-requisites are:

 * Having an account on [Red Hat Hybrid Cloud](https://cloud.redhat.com/).
 * Having the `rhoas` CLI tool installed by following instructions [here](https://github.com/redhat-developer/app-services-guides/tree/main/rhoas-cli#installing-the-rhoas-cli).
 * Logging into your own Red Hat Hybrid Cloud account via `rhoas login` command by following instructions [here](https://github.com/redhat-developer/app-services-guides/tree/main/rhoas-cli#logging-in-to-rhoas).

## Create Apache Kafka instance

Create the Apache Kafka instance by running the following command:

```shell
rhoas kafka create --name formula1-kafka --wait
```

It specifis the `--name` option with the name of the instance and instructs the command to run synchronously by waiting for the instance to be ready using the `--wait` option.
The command will exit when the instance is ready providing some related information in JSON format like following.

```shell
✔️  Kafka instance "formula1-kafka" has been created:
{
  "bootstrap_server_host": "formula-j-d-nks-g-f-pqm---fmvg.bf2.kafka.rhcloud.com:443",
  "cloud_provider": "aws",
  "created_at": "2022-01-23T11:35:47.142502Z",
  "href": "/api/kafkas_mgmt/v1/kafkas/c8nkp5i1e9ohm495fnvd",
  "id": "c8nkp5i1e9ohm495fnvd",
  "instance_type": "eval",
  "kind": "Kafka",
  "multi_az": true,
  "name": "formula1-kafka",
  "owner": "ppatiern",
  "reauthentication_enabled": true,
  "region": "us-east-1",
  "status": "ready",
  "updated_at": "2022-01-23T11:40:24.253791Z",
  "version": "2.8.1"
}
```

To confirm that everything is fine, verify the status of the Kafka instance by running the following command:

```shell
rhoas status kafka
```

The output will show status and bootstrap URL of the Kafka instance.

```shell
Kafka
--------------------------------------------------------------------------------
ID:                     c8nkp5i1e9ohm495fnvd
Name:                   formula1-kafka
Status:                 ready
Bootstrap URL:          formula-j-d-nks-g-f-pqm---fmvg.bf2.kafka.rhcloud.com:443
```

## Create topics

Create the topics needed by the application.

```shell
rhoas kafka topic create --name f1-telemetry-drivers
rhoas kafka topic create --name f1-telemetry-events
rhoas kafka topic create --name f1-telemetry-packets
rhoas kafka topic create --name f1-telemetry-drivers-avg-speed
rhoas kafka topic create --name f1-telemetry-drivers-laps
```

Each command will print the topic configuration.
Check that all topics are created  by running the following command.

```shell
rhoas kafka topic list
```

The output will show the list of the topics on the Kafka instance.

```shell
NAME (5)                         PARTITIONS   RETENTION TIME (MS)   RETENTION SIZE (BYTES)  
-------------------------------- ------------ --------------------- ------------------------ 
f1-telemetry-drivers                      1   604800000             -1 (Unlimited)          
f1-telemetry-drivers-avg-speed            1   604800000             -1 (Unlimited)          
f1-telemetry-drivers-laps                 1   604800000             -1 (Unlimited)          
f1-telemetry-events                       1   604800000             -1 (Unlimited)          
f1-telemetry-packets                      1   604800000             -1 (Unlimited)
```

## Create service accounts and ACLs

### UDP to Apache Kafka

Create a service account for the UDP to Apache Kafka application by running the following command.

```shell
rhoas service-account create --short-description formaula1-udp-kafka --file-format json --output-file ./formula1-udp-kafka.json
```

This will generate a JSON file containing the credentials for accessing the Kafka instance.

```shell
{ 
	"clientID":"srvc-acct-adg23480-dsdf-244a-gt65-d4vd65784dsf", 
	"clientSecret":"f8g93220-9619-55ed-c23d-a2356c1fds9c",
	"oauthTokenUrl":"https://identity.api.openshift.com/auth/realms/rhoas/protocol/openid-connect/token"
}
```

The UDP to Apache Kafka application needs the rights to write on the `f1-telemetry-drivers`, `f1-telemetry-events` and `f1-telemetry-packets` topics.
To simplify let's grent access as a producer on topics starting with `f1-` prefix.

```shell
rhoas kafka acl grant-access --producer --service-account srvc-acct-adg23480-dsdf-244a-gt65-d4vd65784dsf --topic-prefix f1-
```

In this way the following ACLs entries will be created for the corresponding service account.

```shell
PRINCIPAL                                        PERMISSION   OPERATION   DESCRIPTION              
------------------------------------------------ ------------ ----------- ------------------------- 
srvc-acct-adg23480-dsdf-244a-gt65-d4vd65784dsf   allow        describe    topic starts with "f1-"  
srvc-acct-adg23480-dsdf-244a-gt65-d4vd65784dsf   allow        write       topic starts with "f1-"  
srvc-acct-adg23480-dsdf-244a-gt65-d4vd65784dsf   allow        create      topic starts with "f1-"  
srvc-acct-adg23480-dsdf-244a-gt65-d4vd65784dsf   allow        write       transactional-id is "*"  
srvc-acct-adg23480-dsdf-244a-gt65-d4vd65784dsf   allow        describe    transactional-id is "*" 
```

### Apache Kafka to InfluxDB

Create a service account for the Apache Kafka to InfluxDB application by running the following command.

```shell
rhoas service-account create --short-description formaula1-kafka-influxdb --file-format json --output-file ./formaula1-kafka-influxdb.json
```

This will generate a JSON file containing the credentials for accessing the Kafka instance.

```shell
{ 
	"clientID":"srvc-acct-abc1234-dsdf-244a-gt65-d4vd65784dsf", 
	"clientSecret":"g6d12345-9619-55ed-c23d-a2356c1fds9c",
	"oauthTokenUrl":"https://identity.api.openshift.com/auth/realms/rhoas/protocol/openid-connect/token"
}
```

The Apache Kafka to InfluxDB application needs the rights to read from the `f1-telemetry-drivers`, `f1-telemetry-events` and `f1-telemetry-drivers-avg-speed` topics.
To simplify let's grent access as a consumer on topics starting with `f1-` prefix.

```shell
rhoas kafka acl grant-access --consumer --service-account srvc-acct-abc1234-dsdf-244a-gt65-d4vd65784dsf --topic-prefix f1- --group all
```

In this way the following ACLs entries will be created for the corresponding service account.

```shell
PRINCIPAL                                        PERMISSION   OPERATION   DESCRIPTION              
------------------------------------------------ ------------ ----------- ------------------------- 
srvc-acct-abc1234-dsdf-244a-gt65-d4vd65784dsfa   allow        describe    topic starts with "f1-"  
srvc-acct-abc1234-dsdf-244a-gt65-d4vd65784dsfa   allow        read        topic starts with "f1-"  
srvc-acct-abc1234-dsdf-244a-gt65-d4vd65784dsfa   allow        read        group is "*"
```