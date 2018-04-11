#!/usr/bin/env bash

source ./provision_utils.sh

# Provision the following resources
# Notes:
# * STACK_NAME must be unique and can contain only alphanumeric characters (case sensitive) and hyphens.
#   It must start with an alphabetic character and cannot be longer than 128 characters.

# Keep this at the end to automatically de-provision stacks.
deprovision
