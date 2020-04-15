#!/usr/bin/env bash

MIZ_DIR=$1

MIZ_FILE="${MIZ_DIR}.miz"

echo Packing $MIZ_DIR to $MIZ_FILE
rm -f "$MIZ_FILE"
(cd "$MIZ_DIR" && 7z a -tzip "../$MIZ_FILE" .)
rm -rf "$MIZ_DIR"