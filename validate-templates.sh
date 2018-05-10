#!/usr/bin/env bash
set -ex

TEMPLATES=templates/*

for template in $TEMPLATES
do
  dir="${template%/*}"
  file="${template##*/}"
  extension="${file##*.}"
  filename="${file%.*}"
  "sceptre --var \"profile=default\" --var \"region=us-east-1\" validate-template prod $filename"
done

set +ex
