#!/bin/bash
# Deploys the pipeline in the Tools account

source ../env/env_accounts.sh
source ../env/env_deployment.sh

# Replace with your docker build image repo name in ECR
BuildImageRepo=my-build-image

echo "Deploying Pipeline..."
aws cloudformation deploy --stack-name example-pipeline\
    --template-file example_pipeline.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $ToolsAccountProfile \
    --parameter-overrides \
        TestAccount=$TestAccount \
        ProdAccount=$ProdAccount  \
        ExternPipelineAccessRoleName=$ExternPipelineAccessRoleName \
        CloudformationDeployerRoleName=$CloudformationDeployerRoleName \
        BuildImageRepo=$BuildImageRepo
