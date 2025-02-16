# tf-aws-ec2-motd-demo

This is a demo Terraform project that provisions an AWS environment with a VPC and three EC2 instances running different AMIs (Amazon Linux 2023, Amazon Linux 2, and Ubuntu). The focus of this demo is on configuring and displaying the Message of the Day (MOTD) on provisioned instances.

## Prerequisites

Before using this Terraform configuration, ensure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://aws.amazon.com/cli/) (configured with appropriate credentials)
- An AWS account with necessary permissions

## Configuration

This configuration deploys:

- A VPC in `ap-southeast-2`
- Public and private subnets
- Three EC2 instances:
  - Amazon Linux 2023
  - Amazon Linux 2
  - Ubuntu

## Usage

### Initialize Terraform

Run the following command to initialize Terraform:

```sh
terraform init
```

### Apply the Configuration

To create the infrastructure, run:

```sh
terraform apply -auto-approve
```

This will provision the VPC and the EC2 instances.

### Destroy the Infrastructure

To delete all resources created by this Terraform configuration, run:

```sh
terraform destroy -auto-approve
```

## Notes

- The `tfstack/vpc/aws` module is used to provision the VPC.
- The `data.http.my_public_ip` data source fetches the public IP of the user to restrict SSH access.
- EC2 instances are provisioned with a cloud-init configuration (`external/cloud-init.yaml`).
- The `-auto-approve` flag is used to skip confirmation prompts during `terraform apply` and `terraform destroy`.

## Cleanup

Always ensure to destroy the resources after testing to avoid unnecessary costs:

```sh
terraform destroy -auto-approve
```
