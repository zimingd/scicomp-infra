# Overview
Install, configure and manage the AWS scicomp account.


## Instructions to create or update CF stacks

```
# unlock repo
git-crypt unlock
# set env vars
source env_vars && source env_vars.secret
# Run commands in update_cf_stack.sh to update CF stacks
```

The above should setup resources for the account.  Once the infrastructure for the account has been setup
you can access and view the account using the [AWS console](https://AWS-account-ID-or-alias.signin.aws.amazon.com/console).

*Note - This project depends on CF templates from other accounts.*

## Scicomp

### Provision EC2 instances

```
aws --profile scicomp --region us-east-1 \                                                                                                                            master ◼
cloudformation create-stack --stack-name khai-instance1 \
--capabilities CAPABILITY_NAMED_IAM \
--template-url https://s3.amazonaws.com/bootstrap-awss3cloudformationbucket-114n2ojlbvj21/scicomp-infra/master/accounts.yml \
--parameters \
ParameterKey=InstanceType,ParameterValue="t2.nano" \
ParameterKey=JcServiceApiKey,ParameterValue="abcd111122223333aaaabbbbccccddddeeeeffff" \
ParameterKey=JcSystemsGroupId,ParameterValue="1eabd8df45bf6d7d2a32d4ff"
```
*Note* - check default parameters in the template

The above should create an EC2 instance and join the instance to a Sage Jumpcloud "system group"
identified by $JcSystemsGroupId.  Jumpcloud "User groups" that have access to $JcSystemsGroupId
will have access to this instance.

### Workflow

This is how EC2 provisioning works for this account.

1. Create the EC2 instance with the above command.
2. Locate the IP address of the newly provisioned EC2 instance.
3. Login to the Sage VPN. (only required if the instance is in a private subnet)
4. ssh to the ip address with a jumpcloud user account and ssh key (i.e. ssh jsmith@10.5.67.102)

## Continuous Integration
We have configured Travis to deploy CF template updates.  Travis does this by running update_cf_stack.sh on every
change.


# Contributions

## Issues
* https://sagebionetworks.jira.com/projects/IT

## Builds
* https://travis-ci.org/Sage-Bionetworks/scicomp-infra

## Secrets
* We use [git-crypt](https://github.com/AGWA/git-crypt) to hide secrets.
Access to secrets is tightly controlled.  You will be required to
have your own [GPG key](https://help.github.com/articles/generating-a-new-gpg-key)
and you must request access by a maintainer of this project.
