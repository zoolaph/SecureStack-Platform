#!/bin/bash
mkdir ~/.tmp && cd $_

mkdir ~/.bin && cd $_
wget https://raw.githubusercontent.com/pahud/vscode/main/.devcontainer/bin/aws-sso-credential-process && \
chmod +x aws-sso-credential-process

aws configure set credential_process ${HOME}/.bin/aws-sso-credential-process
touch ~/.aws/credentials && chmod 600 $_
aws configure sso --profile default

