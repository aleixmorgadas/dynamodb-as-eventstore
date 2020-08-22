#!/usr/bin/env bash

rm -rf ./.terraform

terraform init

terraform destroy

