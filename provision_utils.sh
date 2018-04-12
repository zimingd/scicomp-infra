#!/usr/bin/env bash

# This file contains functions to help auto provision and deprovision stacks.
# It is meant to be run in a Travis environment and depends on variables sourced from .travis.yml file

# Get committer info from Travis environment
COMMITTER_EMAIL="$(git log -2 $TRAVIS_COMMIT --pretty="%cE"|grep -v -m1 noreply@github.com)"
AUTHOR_NAME="$(git log -1 $TRAVIS_COMMIT --pretty="%aN")"

# Function to provision EC2 instances. The stack_name is always prepended by "ap-"
function provision_ec2 {
  local l_stack_name="ap-$1"
  local l_department=$2
  local l_project=$3
  local l_instance_type=$4
  local l_cf_template=$5
  local l_subnet=${6:-"PrivateSubnet"}
  local l_provision_cmd="aws cloudformation create-stack \
  --stack-name $l_stack_name \
  --capabilities CAPABILITY_NAMED_IAM \
  --on-failure DELETE \
  --notification-arns $CloudformationNotifyLambdaTopicArn \
  --template-body file://cf_templates/$l_cf_template \
  --parameters \
  ParameterKey=VpcName,ParameterValue="computevpc" \
  ParameterKey=VpcSubnet,ParameterValue="$l_subnet" \
  ParameterKey=KeyName,ParameterValue="scicomp" \
  ParameterKey=Department,ParameterValue=\"$l_department\" \
  ParameterKey=Project,ParameterValue=\"$l_project\" \
  ParameterKey=OwnerEmail,ParameterValue=\"$COMMITTER_EMAIL\" \
  ParameterKey=InstanceType,ParameterValue=\"$l_instance_type\" \
  ParameterKey=JcServiceApiKey,ParameterValue=\"$JcServiceApiKey\" \
  ParameterKey=JcSystemsGroupId,ParameterValue=\"$JcSystemsGroupId\" \
  ParameterKey=JcConnectKey,ParameterValue=\"$JcConnectKey\""
  local l_message=$($l_provision_cmd 2>&1 1>/dev/null)
  local l_status_code=$(echo $?)
  if [[ $l_status_code -ne 0 ]]; then
    echo $l_message
    return $l_status_code
  elif [[ $l_message =~ .*"AlreadyExistsException".* ]]; then
    echo -e "\nStack $l_stack_name already exists"
    return 0
  else
    echo -e "\nCreating stack $l_stack_name with template cf_templates/$l_cf_template ..."
    # wait for stack deployment to complete to get the ip address of the instance
    aws cloudformation wait stack-create-complete --stack-name $l_stack_name
    l_status_code=$(echo $?)
    if [[ l_status_code -eq 255 ]]; then
      echo -e "\nFailed getting status of $l_stack_name"
      exit $l_status_code
    else
      echo -e "\nSending provisioned resource info..."
      local l_instance_ip="$(aws cloudformation describe-stacks --stack-name $l_stack_name | jq -r '.Stacks[0].Outputs[0].OutputValue')"
      aws ses send-email --to "$COMMITTER_EMAIL" --subject "Scicomp Automated Provisioning" \
      --text "An EC2 instance has been provisioned for you. To connect to this resource, login to the Sage VPN then type \"ssh <YOUR_JUMPCLOUD_USERNAME>@$l_instance_ip\" (i.e. ssh jsmith@$l_instance_ip)" \
      --from "$OperatorEmail"
    fi
  fi
  return 0
}

# Use git diff to find stacks that have been removed and delete them from AWS
function deprovision {
  local l_git_del_lines=$(git diff -U0 HEAD~1 | grep '^[-]' | grep -Ev '^(--- a/|\+\+\+ b/)' | grep "\-STACK_NAME=" | tr -d '"')

  for git_del_line in $l_git_del_lines
  do
    IFS='=' read -ra stack_keypair <<< "$git_del_line"
    for i in "${!stack_keypair[@]}"; do
      if [ $i -eq 1 ]; then
        l_stacks+=("ap-${stack_keypair[$i]}")
      fi
    done
  done

  for stack in "${l_stacks[@]}"; do
    echo -e "\nDeleting CF stack $stack"
    aws cloudformation delete-stack --stack-name $stack
  done
}
