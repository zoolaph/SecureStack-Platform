#!/bin/bash
set -e

# Create a dedicated folder for the script
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN

mkdir -p ~/.aws/bin
cd ~/.aws/bin

# Download the script
wget https://raw.githubusercontent.com/pahud/vscode/main/.devcontainer/bin/aws-sso-credential-process -O aws-sso-credential-process

# Make it executable
chmod +x aws-sso-credential-process

# Point AWS CLI to use it for the default profile
aws configure set credential_process "${HOME}/.aws/bin/aws-sso-credential-process" --profile default

# Prepare credentials file (empty but correct perms)
mkdir -p ~/.aws
touch ~/.aws/credentials
chmod 600 ~/.aws/credentials

# Run SSO config wizard
aws configure sso --profile default
