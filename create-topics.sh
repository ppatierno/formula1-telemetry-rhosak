#!/usr/bin/env bash

f1Topics=("f1-telemetry-drivers" "f1-telemetry-events" "f1-telemetry-packets" "f1-telemetry-drivers-avg-speed" "f1-telemetry-drivers-laps")

for topic in ${f1Topics[@]}; do
    echo "Creating topic $topic"
    rhoas kafka topic create --name $topic 1> /dev/null
done