#!/usr/bin/env bash
COMMITTER_EMAIL="$(git log -2 $TRAVIS_COMMIT --pretty="%cE"|grep -v -m1 noreply@github.com)"
AUTHOR_NAME="$(git log -1 $TRAVIS_COMMIT --pretty="%aN")"

# EC2 instance for demo
STACK_NAME="ec2-test2"
DEPARTMENT="Platform"
PROJECT="Infrastructure"
INSTANCE_TYPE="t2.nano"
CF_TEMPLATE="ec2.yml"
CLI_CMD="aws cloudformation create-stack \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--on-failure DELETE \
--notification-arns $CloudformationNotifyLambdaTopicArn \
--template-body file://cf_templates/$CF_TEMPLATE \
--parameters \
ParameterKey=VpcName,ParameterValue="computevpc" \
ParameterKey=VpcSubnet,ParameterValue="PrivateSubnet" \
ParameterKey=KeyName,ParameterValue="scicomp" \
ParameterKey=Department,ParameterValue=\"$DEPARTMENT\" \
ParameterKey=Project,ParameterValue=\"$PROJECT\" \
ParameterKey=OwnerEmail,ParameterValue=\"$COMMITTER_EMAIL\" \
ParameterKey=InstanceType,ParameterValue=\"$INSTANCE_TYPE\" \
ParameterKey=JcServiceApiKey,ParameterValue=\"$JcServiceApiKey\" \
ParameterKey=JcSystemsGroupId,ParameterValue=\"$JcSystemsGroupId\" \
ParameterKey=JcConnectKey,ParameterValue=\"$JcConnectKey\""
message=$($CLI_CMD 2>&1 1>/dev/null)
error_code=$(echo $?)
if [[ $error_code -ne 0 && $message =~ .*"AlreadyExistsException".* ]]; then
  error_code=0
elif [[ $error_code -ne 0 ]]; then
  echo $message
  exit $error_code
else
  echo -e "\nCreating stack $STACK_NAME with template cf_templates/$CF_TEMPLATE"
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
  status_code=$(echo $?)
  if [[ status_code -eq 255 ]]; then
    echo -e "\nFailed getting status of $STACK_NAME"
    exit $status_code
  else
    echo -e "\nSending provisioned resource info..."
    EC2_IP="$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[0].Outputs[0].OutputValue')"
    aws ses send-email --to "$COMMITTER_EMAIL" --subject "Scicomp Automated Provisioning" \
    --text "An EC2 instance has been provisioned for you. To connect to this resource, login to the Sage VPN then type \"ssh <YOUR_JUMPCLOUD_USERNAME>@$EC2_IP\" (i.e. ssh jsmith@$EC2_IP)" \
    --from "$OperatorEmail"
  fi
fi
