#!/usr/bin/env bash

CF_BUCKET_URL="https://s3.amazonaws.com/bootstrap-awss3cloudformationbucket-19qromfd235z9/master"

STACK_NAME="bootstrap"
CF_TEMPLATE="$STACK_NAME.yml"
echo -e "\nDeploying CF template $CF_BUCKET_URL/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $CF_BUCKET_URL/$CF_TEMPLATE"
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
echo -e "\nDeploying CF template $CF_BUCKET_URL/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $CF_BUCKET_URL/$CF_TEMPLATE \
--parameters \
ParameterKey=FhcrcVpnCidrip,ParameterValue=\"$FhcrcVpnCidrip\" \
ParameterKey=OperatorEmail,ParameterValue=\"$OperatorEmail\""
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
echo -e "\nDeploying CF template cf_templates/$CF_TEMPLATE"
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

# must manually create an EC2 key pair (awsKeyName) before creating sophos-utm stack
STACK_NAME="sophos-utm"
CF_TEMPLATE="autoscaling.template"
echo -e "\nDeploying CF template $CF_BUCKET_URL/$CF_TEMPLATE"
UPDATE_CMD="aws cloudformation update-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-url $CF_BUCKET_URL/$CF_TEMPLATE \
--parameters \
ParameterKey=awsLicenseType,ParameterValue="Hourly" \
ParameterKey=awsAvailabilityZone1,ParameterValue="us-east-1a" \
ParameterKey=awsAvailabilityZone2,ParameterValue="us-east-1d" \
ParameterKey=awsNetworkPrefix,ParameterValue=\"VpcSubnetPrefix\" \
ParameterKey=awsTrustedNetwork,ParameterValue=\"$FhcrcVpnCidrip\" \
ParameterKey=basicHostname,ParameterValue="sophosutm" \
ParameterKey=basicAdminEmail,ParameterValue=\"$OperatorEmail\" \
ParameterKey=basicAdminPassword,ParameterValue=\"$SophosInitAdminPassword\" \
ParameterKey=basicOrganization,ParameterValue="Sage-Bionetworks" \
ParameterKey=basicCity,ParameterValue="Seattle" \
ParameterKey=basicCountry,ParameterValue="United States" \
ParameterKey=awsKeyName,ParameterValue="sophosutm" \
ParameterKey=debugMode,ParameterValue="on""
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
