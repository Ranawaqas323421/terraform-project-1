# Terraform Multi-Environment Project (Dev / Stg / Prd)

This project provisions AWS infrastructure across three environments — **Dev**, **Stg**, and **Prd** — using a single Terraform codebase and **Terraform Workspaces**. Resource counts and the EC2 AMI (OS) automatically scale based on the selected workspace, with no manual `.tfvars` input required.

## Architecture

| Environment | OS (AMI)      | EC2 Instances | S3 Buckets | DynamoDB Tables |
|-------------|---------------|----------------|------------|------------------|
| `dev`       | Amazon Linux  | 2              | 1          | 1                |
| `stg`       | Ubuntu 22.04  | 3              | 2          | 2                |
| `prd`       | RHEL 9        | 4              | 3          | 3                |

Environment-specific settings are defined once in a `locals` block inside `main.tf`. Terraform automatically picks the correct configuration based on `terraform.workspace` — switching workspaces is all that's needed to scale infrastructure up or down per environment.

## Resources Created

- **EC2 Instances** (`aws_instance`) — count and AMI vary per workspace
- **EC2 Key Pair** (`aws_key_pair`) — imported from a local public key, named per workspace to avoid collisions
- **S3 Buckets** (`aws_s3_bucket`) — with a random suffix for global uniqueness
- **DynamoDB Tables** (`aws_dynamodb_table`) — on-demand billing (`PAY_PER_REQUEST`)

## Project Structure

```
.
├── main.tf        # Providers, locals (env config), and all resources
├── outputs.tf     # Instance IDs, bucket names, table names
├── waqas3231      # Private SSH key (excluded from git via .gitignore)
├── waqas3231.pub  # Public SSH key
└── .gitignore
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- AWS CLI configured with valid credentials (`aws configure` or exported env vars)
- An SSH key pair (public key file referenced in `main.tf`)

## Usage

Initialize Terraform:
```bash
terraform init
```

Select or create a workspace for the environment you want:
```bash
terraform workspace new dev      # first time only
terraform workspace select dev   # subsequent times
```

Apply — no `-var-file` needed, values are picked up automatically based on workspace:
```bash
terraform apply
```

Repeat for other environments:
```bash
terraform workspace select stg
terraform apply

terraform workspace select prd
terraform apply
```

View outputs at any time:
```bash
terraform output
```

## Destroying Resources

Each workspace must be destroyed individually:
```bash
terraform workspace select dev
terraform destroy

terraform workspace select stg
terraform destroy

terraform workspace select prd
terraform destroy
```

## Notes

- `terraform.tfstate` files, the private key, and `.terraform/` are excluded from version control via `.gitignore`.
- AWS credentials must be valid and unexpired (especially relevant for temporary/session-based credentials such as AWS Academy Learner Lab).
- The EC2 instances use an existing subnet ID specified directly in `main.tf` — update this if deploying into a different VPC/subnet.
