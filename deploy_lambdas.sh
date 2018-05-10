#!/usr/bin/env bash
set -e

# upload lambda packages
S3_BUCKET="essentials-awss3lambdaartifactsbucket-1ef8sqdil160e"
S3_BUCKET_PATH="scicomp-infra/$TRAVIS_BRANCH"

LAMBDA_DIRS=$(ls -d lambda/*)
for lambda_dir in $LAMBDA_DIRS
do
  lambda_name="${lambda_dir##*/}"
  lambda_package="${lambda_name}.zip"
  echo -e "\nPackaging lambda ${lambda_name}"
  pushd lambda/${lambda_name}
  zip -r ../${lambda_package} *
  popd
  echo -e "\nUploading lambda package to s3://$S3_BUCKET/$S3_BUCKET_PATH/${lambda_package}"
  aws s3 cp lambda/${lambda_package} s3://$S3_BUCKET/$S3_BUCKET_PATH/${lambda_package}
done
