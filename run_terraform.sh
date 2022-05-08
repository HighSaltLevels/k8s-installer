#!/bin/bash

set -e

ORIG_DIR=$(pwd)
trap "cd ${ORIG_DIR}" EXIT

cd terraform
terraform plan -out tfplan
terraform apply tfplan
