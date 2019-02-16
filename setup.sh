#!/bin/bash
#
# This script creates the cross account continuous deployment setup.
#

source ./env/env_accounts.sh

echo -n "Setting up Roles in Test and Prod"

ExternPipelineAccessRoleName=extern_pipeline_access_role
CloudformationDeployerRoleName=cloudformation_deployer_role

aws cloudformation deploy --stack-name deployer-iam-roles \
    --template-file stage_account/deployer_iam_roles.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $TestAccountProfile \
    --parameter-overrides \
        ToolsAccount=$ToolsAccount \
        ExternPipelineAccessRoleName=$ExternPipelineAccessRoleName \
        CloudformationDeployerRoleName=$CloudformationDeployerRoleName 

aws cloudformation deploy --stack-name deployer-iam-roles \
    --template-file stage_account/deployer_iam_roles.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $ProdAccountProfile \
    --parameter-overrides \
        ToolsAccount=$ToolsAccount  \
        ExternPipelineAccessRoleName=$ExternPipelineAccessRoleName \
        CloudformationDeployerRoleName=$CloudformationDeployerRoleName 
echo -e "------------------------------------------------------------------------"

echo -e "Setting up resources for the pipeline"
aws cloudformation deploy --stack-name pipeline-resources-setup \
    --template-file tools_account/pipeline_resources_setup.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $ToolsAccountProfile \
    --parameter-overrides \
        DevAccount=$DevAccount \
        TestAccount=$TestAccount \
        ProdAccount=$ProdAccount \
        ExternPipelineAccessRoleName=$ExternPipelineAccessRoleName \
        CloudformationDeployerRoleName=$CloudformationDeployerRoleName 


ArtifactBucket=$(aws cloudformation list-exports --profile $ToolsAccountProfile \
    --query 'Exports[?Name==`ArtifactBucket`].{value:Value}' --output text)

KeyArn=$(aws cloudformation list-exports --profile $ToolsAccountProfile \
    --query 'Exports[?Name==`KmsKeyArn`].{value:Value}' --output text)

# Write outputs to file so that they can be reference later when creating pipelines
echo -e "ArtifactBucket=$ArtifactBucket\nKeyArn=$KeyArn" > ./env/env_deployment.sh
echo -e "ExternPipelineAccessRoleName=$ExternPipelineAccessRoleName\nCloudformationDeployerRoleName=$CloudformationDeployerRoleName" >> ./env/env_deployment.sh


echo -e "Setting up Policies in Test and Prod"
aws cloudformation deploy --stack-name deployer-iam-policies \
    --template-file stage_account/deployer_iam_policies.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $TestAccountProfile \
    --parameter-overrides \
        KeyArn=$KeyArn  \
        ArtifactBucket=$ArtifactBucket 

aws cloudformation deploy --stack-name deployer-iam-policies \
    --template-file stage_account/deployer_iam_policies.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $ProdAccountProfile \
    --parameter-overrides \
        KeyArn=$KeyArn  \
        ArtifactBucket=$ArtifactBucket 
echo -e "------------------------------------------------------------------------"

echo -e "Granting permissions to Dev: step 1"
aws cloudformation deploy --stack-name pipeline-grant-dev-access \
    --template-file tools_account/pipeline_grant_dev_access.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $ToolsAccountProfile \
    --parameter-overrides \
        DevAccount=$DevAccount  
        
RoleName=$(aws cloudformation list-exports --profile $ToolsAccountProfile \
    --query 'Exports[?Name==`DevAccountRole`].{value:Value}' --output text)

echo -e "\nGranting permissions to Dev: step 2"
aws cloudformation deploy --stack-name pipeline-receive-dev-access \
    --template-file dev_account/pipeline_receive_dev_access.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile $DevAccountProfile \
    --parameter-overrides \
        ToolsAccount=$ToolsAccount \
        RoleName=$RoleName

echo -e "------------------------------------------------------------------------"
echo -e "A group was created in the dev account for accessing pipelines called PipelineAccess."
echo -e "You should add to this group the users to whom you want to grant access."
echo -e "Members of the group can assume the role dev_account_role in the Tools account, and then access the pipelines"

