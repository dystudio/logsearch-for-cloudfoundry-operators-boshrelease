#!/bin/bash -ex

ORIGIN="/var/vcap/store/parser/archive"
DESTINATION="/var/vcap/store/parser/logs-to-be-archived"
mkdir -p "$DESTINATION"

for archive in $(ls -1 -t "$ORIGIN" | awk 'NR > 1'); do
  base=$(basename $archive .log.gz)
  mv "$ORIGIN/$archive" "$DESTINATION/$base-$(hostname).log.gz"
done

