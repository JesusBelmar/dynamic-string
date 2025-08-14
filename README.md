# AWS Dynamic String Challenge

## Challenge Description

Create a cloud service that serves an HTML page displaying a dynamically configurable string **without requiring redeployment** when the string changes.

---

## Objective

- Serve an HTML page with the following content:

```html
<h1>The stored string is [dynamic_value]</h1>
```

- The dynamic value must be modifiable via configuration (without code changes).
- Accessible via a public URL.
- All users accessing the URL must see the same value.
- Deploy the entire infrastructure with **Terraform**.

---

## Proposed Solution

### Architecture

```Mermaid graph LR
A[User] --> B[API Gateway]
B --> C[Lambda]
C --> D[SSM Parameter Store]
```

**Flow:**

1. The user accesses the public API Gateway URL.
2. API Gateway invokes a Lambda function written in Python 3.12.
3. Lambda retrieves the dynamic value from the AWS SSM Parameter Store.
4. Lambda constructs and returns the HTML with the updated value.
5. Any changes to SSM are immediately visible to all users.

---

## Project Setup

### 1. Prerequisites

```bash
# Install Required Tools
brew install terraform awscli python

# Check Versions
terraform -v # >= 1.8.0
aws --version # >= 2.0
python3 --version # >= 3.12
```

### 2. AWS Configuration

```bash
aws configure
# Enter AWS credentials when prompted
```

### 3. Clone Repository

```bash
git clone https://github.com/your-user/dynamic-string.git
cd dynamic-string
```

---

## Deployment Steps

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Review the Execution Plan

```bash
terraform plan
```

### 3. Deploy Infrastructure

```bash
terraform apply -auto-approve
```

### 4. Get the Public URL

```bash
terraform output -raw api_gateway_url
```

---

## How It Works

### AWS SSM Parameter Store

- Parameter: `/challenge/dynamic_string`
- Type: `String`
- Update via CLI or console:

```bash
aws ssm put-parameter --name "/challenge/dynamic_string" --value "new-value" --type String --overwrite
```

### AWS Lambda

- Python 3.12
- Read the parameter from SSM with boto3
- Generate the dynamic HTML

### API Gateway

- Endpoint Public HTTPS
- GET method that invokes Lambda

---

## Solution Testing

### 1. Initial Verification

```bash
curl https://<api_id>.execute-api.<region>.amazonaws.com/prod
# <h1>The saved string is: hello-world</h1>
```

### 2. Change the String

```bash
aws ssm put-parameter --name "/challenge/dynamic_string" --value "updated-string" --type String --overwrite
```

### 3. Verify Change

```bash
curl https://<api_id>.execute-api.<region>.amazonaws.com/prod
# <h1>The saved string is: updated-string</h1>
```

---

## Monitoring

### Lambda Logs

```bash
aws logs tail /aws/lambda/dynamic-string --follow
```

---

## Cleanup

Destroy infrastructure:

```bash
terraform destroy -auto-approve
```

Delete SSM parameter:

```bash
aws ssm delete-parameter --name "/challenge/dynamic_string"
```

---

## Project Structure

```plaintext
├── lambda/
│ └── handler.py # Lambda Code
├── terraform/
│ ├── main.tf # Infrastructure
│ ├── variables.tf
│ └── outputs.tf
└── README.md
```

---

## License

Apache 2.0 – see LICENSE file for details.
