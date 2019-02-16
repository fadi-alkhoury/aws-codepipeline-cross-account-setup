#!/bin/bash
#
# This script deletes all resources created with setup.sh.
#

source ./env/env_accounts.sh

aws cloudformation  delete-stack --profile $TestAccountProfile --stack-name deployer-iam-roles
aws cloudformation  delete-stack --profile $ProdAccountProfile --stack-name deployer-iam-roles
aws cloudformation  delete-stack --profile $TestAccountProfile --stack-name deployer-iam-policies
aws cloudformation  delete-stack --profile $ProdAccountProfile --stack-name deployer-iam-policies
aws cloudformation  delete-stack --profile $ToolsAccountProfile --stack-name pipeline-grant-dev-access
aws cloudformation  delete-stack --profile $DevAccountProfile --stack-name pipeline-receive-dev-access
aws cloudformation  delete-stack --profile $ToolsAccountProfile --stack-name pipeline-receive-event-iam 
aws cloudformation  delete-stack --profile $ToolsAccountProfile --stack-name pipeline-resources-setup


aws cloudformation  describe-stacks --profile $TestAccountProfile --stack-name deployer-iam-roles
aws cloudformation  describe-stacks --profile $ProdAccountProfile --stack-name deployer-iam-roles
aws cloudformation  describe-stacks --profile $TestAccountProfile --stack-name deployer-iam-policies
aws cloudformation  describe-stacks --profile $ProdAccountProfile --stack-name deployer-iam-policies
aws cloudformation  describe-stacks --profile $ToolsAccountProfile --stack-name pipeline-grant-dev-access
aws cloudformation  describe-stacks --profile $DevAccountProfile --stack-name pipeline-receive-dev-access
aws cloudformation  describe-stacks --profile $ToolsAccountProfile --stack-name pipeline-receive-event-iam 
aws cloudformation  describe-stacks --profile $ToolsAccountProfile --stack-name pipeline-resources-setup
