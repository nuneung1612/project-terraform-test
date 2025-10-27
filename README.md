# Terraform IaC Code Generation: LLM Comparison Study

A comprehensive evaluation of 6 Large Language Models for generating Terraform Infrastructure as Code across 8 real-world AWS scenarios.

## 📊 Models Tested

### Commercial Models (Official Web Interfaces)
- **Gemini 2.5 Pro** - Google AI Studio
- **ChatGPT 5** - OpenAI Platform
- **Claude Sonnet 4.5** - Anthropic Console

### Open Source Models (Local Inference)
- **Llama 3.1 8B** - Meta
- **Ministral 8B Instruct 2410** - Mistral AI
- **Qwen 2.5 Coder 7B** - Alibaba Cloud

## 🎯 Test Scenarios

Each model was evaluated across 8 progressive AWS infrastructure use cases:

1. **Basic Terraform Configuration** - Provider setup and minimal config
2. **VPC Creation** - Simple Virtual Private Cloud
3. **VPC + Subnets + Routing** - Multi-subnet network with route tables
4. **VPC + EC2 Instance** - Compute resources in custom network
5. **Remote Backend (S3 + DynamoDB)** - State management and locking
6. **EC2 + EFS** - Shared file system integration
7. **Two-Tier Application** - Web + Database layer
8. **Three-Tier Application** - Presentation + Application + Database

## 🔄 Methodology

- **Rounds**: 5 iterations per use case per model
- **Validation**: Each generated configuration tested with `terraform init`, `terraform plan`, `terraform apply`
- **Evaluation Criteria**:
  - ✅ Syntax validity (HCL compliance)
  - ✅ Terraform execution success
  - ✅ Best practices adherence
  - ✅ Resource naming conventions
  - ✅ Security configurations
  - ✅ Code organization

## 🛠️ Open Source Model Setup

For local model inference (Llama, Ministral, Qwen), use the following Python code:

```python
from transformers import pipeline, AutoTokenizer

# Load tokenizer
tokenizer = AutoTokenizer.from_pretrained("<YOUR MODEL HERE>")

# Create pipeline
pipe = pipeline(
    "text-generation",
    model="<YOUR MODEL HERE>",
    device_map="auto"
)

# Prepare messages
messages = [
    {"role": "system", "content": """You are a Terraform IaC expert. Generate code that:
- Uses valid HCL (init/plan/apply works)
- Follows best practices: variable separation, logical structure
- If many resources, separates file by resource type ex. network.tf, compute.tf, database.tf
- Do not use modules
- Uses descriptive names and Name tags
- Prefers data sources; uses id/arn references
- Applies safe defaults
- Implements depends_on where needed
- Marks sensitive variables
- Properly scopes security groups
- Follows Terraform conventions
- Do not generate any code or suggestion more than Infrastructure requirements
Output HCL only unless asked."""},

    {"role": "user", "content": """<YOUR REQUIREMENT HERE>"""}
]

# ========================
# Display RAW PROMPT
# ========================
raw_prompt = tokenizer.apply_chat_template(
    messages,
    tokenize=False,
    add_generation_prompt=True
)

print("=" * 80)
print("RAW PROMPT THAT ACTUALLY SENT TO MODEL:")
print("=" * 80)
print(raw_prompt)
print("=" * 80)

# Generate response
response = pipe(
    messages,
    max_new_tokens=4000,
)
print(response[0]['generated_text'][-1]['content'])
```

### Model Variations

Replace the model name in `AutoTokenizer.from_pretrained()` and `pipeline()`:

- **Llama 3.1 8B**: `"meta-llama/Meta-Llama-3.1-8B-Instruct"`
- **Ministral 8B**: `"mistralai/Ministral-8B-Instruct-2410"`
- **Qwen 2.5 Coder 7B**: `"Qwen/Qwen2.5-Coder-7B-Instruct"`

## 📋 Requirements

### For Open Source Models
```bash
pip install transformers torch accelerate
```

### Hardware Recommendations
- **Minimum**: 16GB RAM, GPU with 8GB VRAM
- **Recommended**: 32GB RAM, GPU with 16GB+ VRAM (for faster inference)

### Terraform
```bash
# Install Terraform
https://developer.hashicorp.com/terraform/install
```

### AWS Credentials
```bash
# Configure AWS CLI
aws configure
```

## 📁 Repository Structure

```
.
├── claude/
│   ├── 1_version/
│   │   ├── 1/
│   │   ├── 2/
│   │   ├── 3/
│   │   ├── 4/
│   │   └── 5/
│   ├── 2_vpc/
│   ├── 3_vpc_sub_rt/
│   ├── 4_vpc_ec2/
│   ├── 5_dynamo_s3/
│   ├── 6_ec2_efs/
│   ├── 7_two_tier/
│   └── 8_three_tier/
├── gemini/
│   ├── 1_version/
│   ├── 2_vpc/
│   ├── 3_vpc_sub_rt/
│   ├── 4_vpc_ec2/
│   ├── 5_dynamo_s3/
│   ├── 6_ec2_efs/
│   ├── 7_two_tier/
│   └── 8_three_tier/
├── gpt-5/
│   ├── 1_version/
│   ├── 2_vpc/
│   ├── 3_vpc_sub_rt/
│   ├── 4_vpc_ec2/
│   ├── 5_dynamo_s3/
│   ├── 6_ec2_efs/
│   ├── 7_two_tier/
│   └── 8_three_tier/
├── llama-3.1-8b/
│   ├── 1_version/
│   ├── 2_vpc/
│   ├── 3_vpc_sub_rt/
│   ├── 4_vpc_ec2/
│   ├── 5_dynamo_s3/
│   ├── 6_ec2_efs/
│   ├── 7_two_tier/
│   └── 8_three_tier/
├── ministral-8B-Instruct-2410/
│   ├── 1_version/
│   ├── 2_vpc/
│   ├── 3_vpc_sub_rt/
│   ├── 4_vpc_ec2/
│   ├── 5_dynamo_s3/
│   ├── 6_ec2_efs/
│   ├── 7_two_tier/
│   └── 8_three_tier/
├── qwen2.5-coder-7b/
│   ├── 1_version/
│   ├── 2_vpc/
│   ├── 3_vpc_sub_rt/
│   ├── 4_vpc_ec2/
│   ├── 5_dynamo_s3/
│   ├── 6_ec2_efs/
│   ├── 7_two_tier/
│   └── 8_three_tier/
├── ref/
├── .gitignore
├── init_3.sh
├── init_allps1
├── init_all.sh
└── README.md
```
### Directory Organization

Each model has its own root directory containing 8 subdirectories for each test case. Within each test case directory, there are 5 subdirectories (1-5) representing the 5 rounds of testing:

- **1_version/** - Basic Terraform Configuration
  - `1/` - Round 1 results
  - `2/` - Round 2 results
  - `3/` - Round 3 results
  - `4/` - Round 4 results
  - `5/` - Round 5 results
- **2_vpc/** - VPC Creation (5 rounds)
- **3_vpc_sub_rt/** - VPC + Subnets + Route Tables (5 rounds)
- **4_vpc_ec2/** - VPC + EC2 Instance (5 rounds)
- **5_dynamo_s3/** - Remote Backend with S3 + DynamoDB (5 rounds)
- **6_ec2_efs/** - EC2 with EFS (5 rounds)
- **7_two_tier/** - Two-Tier Application (5 rounds)
- **8_three_tier/** - Three-Tier Application (5 rounds)

### Initialization Scripts
- **init_3.sh** - Initialize and test specific scenarios
- **init_all.sh** - Batch initialization for all test cases (Linux/macOS)
- **init_allps1** - Batch initialization for all test cases (Windows PowerShell)

### Reference Directory
- **ref/** - Contains reference implementations and documentation




## 🔗 Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [HuggingFace Transformers](https://huggingface.co/docs/transformers)
- [Llama 3.1 Model Card](https://huggingface.co/meta-llama/Meta-Llama-3.1-8B-Instruct)
- [Qwen 2.5 Coder](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct)
- [Ministral Documentation](https://huggingface.co/mistralai/Ministral-8B-Instruct-2410)
- References Terraform code
    - [Ref 1_version](https://developer.hashicorp.com/terraform/language/backend/local)
    - [Ref 2_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
    - [Ref 3_vpc_sub_rt](https://cloudnativeengineer.substack.com/p/enhancing-software-design-with-diagrams)
    - [Ref 4_vpc_ec2](https://github.com/ldpacl/AWS/tree/main/aws_vpc/VPC_sample)
    - [Ref 5_dynamo_s3](https://aws.plainenglish.io/creating-a-terraform-module-for-s3-remote-backend-with-dynamodb-state-locking-17f1df067a8d)
    - [Ref 6_ec2_efs](https://dev.to/chinmay13/getting-started-with-aws-and-terraform-multi-attaching-elastic-file-system-efs-volumes-to-ec2-instances-using-terraform-3289)
    - [Ref 7_two_tier](https://www.devopshint.com/two-tier-architecture-in-aws-using-terraform)
    - [Ref 8_three_tier](https://github.com/mathesh-me/multi-tier-architecture-using-terraform/tree/main)


## 🙏 Acknowledgments

- Anthropic for Claude API access
- OpenAI for ChatGPT API access
- Google for Gemini API access
- HuggingFace for model hosting
- HashiCorp for Terraform

---

**Note**: This is a research project. Generated Terraform code should be reviewed before production use. Always follow security best practices and organizational policies.

**Disclaimer**: Results may vary based on hardware specifications, model versions, and AWS region configurations.
