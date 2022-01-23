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