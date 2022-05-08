#!/usr/bin/env bash

service_accounts=$(rhoas service-account list -o json)

for client_id in $(echo "${service_accounts}" | jq -r .items[].client_id); do
    echo "Deleting ACLs for service account client_id: $client_id"
    rhoas kafka acl delete -y --pattern-type any --service-account $client_id
done

for id in $(echo "${service_accounts}" | jq -r .items[].id); do
    echo "Deleting service account id: $id"
    rhoas service-account delete -y --id $id
done

rm *.env