#!/bin/bash
set -e

# Validate all templates managed by sceptre
TEMPLATES=templates/*
for template in $TEMPLATES
do
  dir="${template%/*}"
  file="${template##*/}"
  extension="${file##*.}"
  filename="${file%.*}"
  echo -e "\nValidating ${template}"
  sceptre --var profile="default" --var region="us-east-1" validate-template prod $filename
done

# Validate the auto provision template
echo -e "\nValidating auto-provision/ec2.yaml"
aws cloudformation validate-template --template-body file://auto-provision/ec2.yaml
