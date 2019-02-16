# Cross-Account Continuous Delivery Pipeline Setup With AWS CodePipeline

This repository contains scripts to create a cross-account account continuous deployment solution. The account setup in this use case is as follows:

|                  |              |
| :--------------- |:-------------|
| **DevAccount**   | The account controlled by developers. |
| **ToolsAccount** | The account controlled by the DevOps team. It contains pipelines and the [AWS CodeCommit](https://aws.amazon.com/codecommit/) repositories. |
| **TestAccount**  | The account with the test environment that can be used for testing within a pipeline.|
| **ProdAccount**  | The production account, where the output of pipelines should be deployed after passing all tests.|

This setup is a variation of the [AWS reference cross-account continuous delivery pipeline](https://aws.amazon.com/blogs/devops/aws-building-a-secure-cross-account-continuous-delivery-pipeline/). The main difference is that the DevOps team controls the repositories and the pipelines, instead of the developers.

## How to create and setup the resources

- Create the accounts listed above, if they are not available.
- Clone this repo.
- Configure the account numbers and the profiles in `env/env_accounts.sh`.
- Replace the artifacts bucket name in `tools_account/pipeline_resources_setup.yaml` with a name suitable for your project.
- Run `setup.sh`
- In your DevAccount, an IAM group `PipelineAccess` was created. Add users to this group to allow (restricted) access to the repositories and the pipelines. The permissions are defined in the `dev_account_pipeline_access` within the ToolsAccount.

To delete all resources, run `delete.sh`.

## Adding pipelines

With all the resources in place, you can add pipelines in your Tools account and configure them to trigger on new commits. See `pipeline_example` for an example of a pipeline that builds and deploys a lambda function.