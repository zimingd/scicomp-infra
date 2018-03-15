#!/usr/bin/env bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
AWS_INFRA_CF_BUCKET_URL="https://s3.amazonaws.com/bootstrap-awss3cloudformationbucket-19qromfd235z9"
CF_BUCKET_URL="https://s3.amazonaws.com/bootstrap-awss3cloudformationbucket-114n2ojlbvj21"

STACK_NAME="bootstrap"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nUpdating $STACK_NAME with template $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
# Handle message that shouldn't be an error, https://github.com/hashicorp/terraform/issues/5653
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="essentials"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nUpdating $STACK_NAME with template $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=FhcrcVpnCidrip,ParameterValue=\"$FhcrcVpnCidrip\" \
ParameterKey=OperatorEmail,ParameterValue=\"$OperatorEmail\" \
ParameterKey=VpcPeeringRequesterAwsAccountId,ParameterValue=\"$AdmincentralAwsAccountId\""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="accounts"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nUpdating $STACK_NAME with template cf_templates/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-body file://cf_templates/$CF_TEMPLATE \
--parameters \
ParameterKey=InitNewUserPassword,ParameterValue=\"$InitNewUserPassword\""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="computevpc"
CF_TEMPLATE="vpc.yml"
echo -e "\nUpdating $STACK_NAME with template $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=VpcName,ParameterValue=\"$STACK_NAME\" \
ParameterKey=VpcSubnetPrefix,ParameterValue="10.5""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

STACK_NAME="peer-vpn-computevpc"
CF_TEMPLATE="peer-route-config.yml"
echo -e "\nUpdating $STACK_NAME with template $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $AWS_INFRA_CF_BUCKET_URL/aws-infra/master/$CF_TEMPLATE \
--parameters \
ParameterKey=PeeringConnectionId,ParameterValue="pcx-e6cd3b8e" \
ParameterKey=VpcPrivateRouteTable,ParameterValue="rtb-5f73c623" \
ParameterKey=VpcPublicRouteTable,ParameterValue="rtb-6e7fca12" \
ParameterKey=VpnCidr,ParameterValue="10.1.0.0/16""
message=$($UPDATE_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"No updates are to be performed".* ]]; then
  echo -e "\nNo stack changes detected. An update is not required."
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo $message
fi

