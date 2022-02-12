#!/usr/bin/env bash

service_accounts=$(rhoas service-account list -o json)

for id in $(echo "${service_accounts}" | jq -r .items[].id); do
    echo "Deleting service account $id"
    rhoas service-account delete -y --id $id
done