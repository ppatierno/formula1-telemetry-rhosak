#!/usr/bin/env bash

f1_topics=$(rhoas kafka topic list -o json)

for topic in $(echo "${f1_topics}" | jq -r .items[].name); do
    echo "Deleting topic $topic"
    rhoas kafka topic delete -y --name $topic
done