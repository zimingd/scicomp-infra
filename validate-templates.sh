#!/bin/bash
set -e

# Validate local templates
TEMPLATES=templates/*
for template in $TEMPLATES
do
  dir="${template%/*}"
  file="${template##*/}"
  extension="${file##*.}"
  filename="${file%.*}"
  echo -e "\nValidating ${template}"
  aws cloudformation validate-template --template-body file://${template}
done


# Validate the auto provision template
echo -e "\nValidating auto-provision/ec2.yaml"
aws cloudformation validate-template --template-body file://auto-provision/ec2.yaml
