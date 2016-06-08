#!/bin/bash -ex

ORIGIN="/var/vcap/store/parser/archive"
DESTINATION="/var/vcap/store/parser/logs-to-be-archived"
mkdir -p "$DESTINATION"

# Aim with this section
# Create files that prevent incoming old data overwriting an archive in s3 (file md5)
for archive in $(ls -1 -t "$ORIGIN" | awk 'NR > 1'); do
  base=$(basename $archive .log.gz)
  md5=$(md5sum "$ORIGIN/$archive" | awk '{print $1}')
  mv "$ORIGIN/$archive" "$DESTINATION/$base-$md5.log.gz"
done

