# Cribl Stream single deployment with Terraform

This is a terraform code for Cribl single deployment from building a VPC, a public subnet and to access to Cribl portal in AWS for those who wants to deploy and use
Cribl Stream promptly.

## Prerequisites

- Clone the `main.tf` and `variables.tf` files to your local environment.
- Set AWS authentication information in the `variables.tf` file.
- Set the VPC and subnet CIDR blocks according to your environment in the `main.tf` file.

## Terraform code

1. Create a directory where your files will be executed. For example:
```
mkdir terraform-cribl
```

2. Initialize Terraform plugin:
```
terraform init
```

3. Check the expected changes before the environment is deployed:
```
terraform plan
```

4. Execute Terraform code:
```
terraform apply
```

5. When you are finished exploring Cribl, make sure to destroy the environment to avoid unnecessary costs:
```
terraform destroy
```

## Access to Cribl Stream

- Cribl Stream is set to use port 9000 by default.
- The default account information is `admin`/`admin`. 
