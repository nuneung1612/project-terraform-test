#!/bin/bash
# --------------------------------------------
# Terraform Init Script for Multi-Model Structure
# Author: ChatGPT
# --------------------------------------------

#cd "TERRAFORM-TEST-GPT-GEMINI-CLAUDE" || exit 1

for model in claude gemini gpt-5; do
  echo ""
  echo ">>> Initializing Terraform for model: $model"
  for i in {1..5}; do
    path="./$model/7_ec2_efs/$i"
    if [ -d "$path" ]; then
      echo "-> Running terraform init in $path"
      (cd "$path" && terraform init)
    else
      echo "-> Skipped missing folder: $path"
    fi
  done
done

echo ""
echo "All Terraform initializations completed!"
