#!/bin/bash
# --------------------------------------------
# Terraform Validation, Plan, and Lint Runner
# For multi-model structure
# Author: ChatGPT (GPT-5)
# --------------------------------------------

rootDir="TERRAFORM-TEST-GPT-GEMINI-CLAUDE"
logDir="$rootDir/logs"
mkdir -p "$logDir"

for model in claude gemini gpt-5; do
  echo ""
  echo ">>> Processing model: $model"
  for i in {1..5}; do
    path="$rootDir/$model/5_three_tier/$i"
    logFile="$logDir/${model}-5_three_tier-$i.log"

    if [ -d "$path" ]; then
      echo "-> Running Terraform in $path"
      {
        echo "===== $(date) ====="
        echo "Running Terraform in: $path"
        echo ""

        terraform init -no-color
        terraform validate -no-color

        if command -v tflint >/dev/null 2>&1; then
          tflint
        else
          echo "tflint not found, skipped"
        fi

        echo ""
        echo "===== End of run for $path ====="
      } > "$logFile" 2>&1

      echo "   ✓ Completed -> $logFile"
    else
      echo "-> Skipped missing folder: $path"
    fi
  done
done

echo ""
echo "✅ All Terraform checks completed! Logs saved in: $logDir"
