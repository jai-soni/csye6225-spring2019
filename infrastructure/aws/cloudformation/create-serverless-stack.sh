#!/bin/bash
# echo "Fetching domain name from Route 53"
# DOMAIN_NAME=$(aws route53 list-hosted-zones --query HostedZones[0].Name --output text)
# DOMAIN_NAME="${DOMAIN_NAME%?}"
# echo "$DOMAIN_NAME"

LAMBDA_BUCKET=$(aws s3api list-buckets | jq -r '.Buckets[] | select(.Name | startswith("lambda")).Name')
echo "LAMBDA_BUCKET: $LAMBDA_BUCKET"
# LAMBDABUCKET="lambda.$DOMAIN_NAME"
# echo "LAMBDA_BUCKET:- $LAMBDABUCKET"

AccountId=$(aws iam get-user|python -c "import json as j,sys;o=j.load(sys.stdin);print o['User']['Arn'].split(':')[4]")
echo "AccountId: $AccountId"

SNSTOPIC_ARN="arn:aws:sns:us-east-1:$AccountId:SNSTopicResetPassword"
echo "SNSTOPIC_ARN: $SNSTOPIC_ARN"

aws cloudformation create-stack --stack-name "serverless" --capabilities "CAPABILITY_NAMED_IAM" --template-body file://./serverless.yaml --parameters ParameterKey=LAMBDABUCKET,ParameterValue=$LAMBDA_BUCKET ParameterKey=SNSTOPICARN,ParameterValue=$SNSTOPIC_ARN
aws cloudformation wait stack-create-complete --stack-name "serverless"
STACKDETAILS=$(aws cloudformation describe-stacks --stack-name "serverless" --query Stacks[0].StackId --output text)

echo "Stack serverless created successfully"
exit 0