# --------------------------------------------
# Terraform Init Script for Multi-Model Structure
# Author: ChatGPT
# --------------------------------------------

# ไปที่โฟลเดอร์หลัก
cd "TERRAFORM-TEST-GPT-GEMINI-CLAUDE"

# รายชื่อโฟลเดอร์โมเดล
$models = @("claude", "gemini", "gpt-5")

# วนรัน terraform init ภายใน 1–5 ของแต่ละโมเดล
foreach ($model in $models) {
    Write-Host "`n>>> Initializing Terraform for model: $model" -ForegroundColor Cyan
    for ($i = 1; $i -le 5; $i++) {
        $path = ".\$model\4_two_tier\$i"
        if (Test-Path $path) {
            Write-Host "-> Running terraform init in $path" -ForegroundColor Yellow
            Push-Location $path
            terraform init
            Pop-Location
        } else {
            Write-Host "-> Skipped missing folder: $path" -ForegroundColor DarkGray
        }
    }
}
Write-Host "`nAll Terraform initializations completed!" -ForegroundColor Green
