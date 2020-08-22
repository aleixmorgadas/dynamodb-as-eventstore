#!/usr/bin/env bash

rm -rf ./.terraform

rm -rf ../build

echo "Building Event Store Lambda\n"
echo "Compressing Dependencies"

mkdir -p ../build
cd ../venv/lib/python3.8/site-packages
zip -r9 ../../../../build/lambda.zip .
cd -
zip -rjg ../build/lambda.zip ../src/eventhandler.py
zip -rjg ../build/lambda.zip ../src/schemavalidation.py

pwd

terraform init

terraform plan -out=eventstore.plan
terraform apply eventstore.plan

rm -f eventstore.plan

