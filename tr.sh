#!/bin/bash

# Initialize Terraform
terraform init

# Generate and show an execution plan
terraform plan

# Apply the Terraform configuration
terraform apply -auto-approve

