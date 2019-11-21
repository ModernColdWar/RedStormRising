#!/usr/bin/env bash

MIZ_FILE=$(realpath $1)

FILENAME=$(basename -- "$MIZ_FILE")
TGT_DIR="${FILENAME%.*}"

echo Unpacking $MIZ_FILE to $TGT_DIR
rm -rf "$TGT_DIR"
mkdir "$TGT_DIR"
cd "$TGT_DIR"
7z x "$MIZ_FILE"
rm "$MIZ_FILE"
