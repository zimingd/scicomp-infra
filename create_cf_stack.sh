#!/usr/bin/env bash

source ./provision_utils.sh

# Provision the following resources
# Notes:
# * STACK_NAME must be unique and can contain only alphanumeric characters (case sensitive) and hyphens.
#   It must start with an alphabetic character and cannot be longer than 128 characters.
STACK_NAME="bastian1"
DEPARTMENT="Platform"
PROJECT="Infrastructure"
INSTANCE_TYPE="t2.nano"
CF_TEMPLATE="ec2.yml"
provision_ec2 $STACK_NAME $DEPARTMENT $PROJECT $INSTANCE_TYPE $CF_TEMPLATE

STACK_NAME="xschildw1"
DEPARTMENT="Platform"
PROJECT="Infrastructure"
INSTANCE_TYPE="t2.nano"
CF_TEMPLATE="ec2.yml"
provision_ec2 $STACK_NAME $DEPARTMENT $PROJECT $INSTANCE_TYPE $CF_TEMPLATE

# Keep this at the end to automatically de-provision stacks.
deprovision
