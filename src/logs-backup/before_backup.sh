#!/bin/bash -ex

ORIGIN="/var/vcap/store/parser/archive"
DESTINATION="/var/vcap/store/parser/logs-to-be-archived"
mkdir -p "$DESTINATION"

for archive in $(ls -1 -t "$ORIGIN" | awk 'NR > 1'); do
  mv "$ORIGIN/$archive" "$DESTINATION"
done

