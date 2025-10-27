#!/bin/bash

# รวมไฟล์ Terraform (.tf และ .tfvars) ในโฟลเดอร์เดียวกัน
# เขียนรวมเป็นไฟล์ merged_terraform.txt
# พร้อมคั่นชื่อไฟล์ก่อนเนื้อหาแต่ละไฟล์

OUTPUT_FILE="merged_terraform.txt"

# ล้างไฟล์เก่าถ้ามี
> "$OUTPUT_FILE"

# รวมไฟล์ .tf และ .tfvars ตามลำดับชื่อ
for file in $(ls *.tf *.tfvars 2>/dev/null | sort); do
  echo "### FILE: $file ###############################################" >> "$OUTPUT_FILE"
  cat "$file" >> "$OUTPUT_FILE"
  echo -e "\n\n" >> "$OUTPUT_FILE"
done

echo "✅ รวมไฟล์ Terraform ทั้งหมดเสร็จสิ้น -> $OUTPUT_FILE"
