# How to Check Data in DynamoDB

Your DynamoDB table name: `deva-iac-assignment-users`
Region: `eu-central-1`

## Method 1: AWS Console (Web Interface)

1. **Go to AWS Console**: https://console.aws.amazon.com/
2. **Navigate to DynamoDB**:
   - Search for "DynamoDB" in the services search
   - Click on "DynamoDB"
3. **Find your table**:
   - Click on "Tables" in the left sidebar
   - Look for `deva-iac-assignment-users`
   - Click on the table name
4. **View data**:
   - Click on "Explore table items" tab
   - You'll see all the items in your table
   - You can filter, sort, and search through the data

## Method 2: AWS CLI Commands

### Prerequisites

Make sure you have AWS credentials configured:

```bash
aws configure
# OR use temporary credentials from AWS SSO/SAML
```

### Basic Commands

#### 1. Scan all items (shows everything)

```bash
aws dynamodb scan --table-name deva-iac-assignment-users --region eu-central-1
```

#### 2. Get cleaner table format output

```bash
aws dynamodb scan --table-name deva-iac-assignment-users --region eu-central-1 --output table
```

#### 3. Get only specific attributes

```bash
aws dynamodb scan \
  --table-name deva-iac-assignment-users \
  --region eu-central-1 \
  --projection-expression "userId"
```

## Method 3: Using Python Script

Create a simple Python script to check DynamoDB:

```python
import boto3
import json

# Initialize DynamoDB client
dynamodb = boto3.client('dynamodb', region_name='eu-central-1')

# Scan the table
response = dynamodb.scan(TableName='deva-iac-assignment-users')

print(f"Total items: {response['Count']}")
print("\nUsers in table:")
for item in response['Items']:
    user_id = item['userId']['S']
    print(f"- {user_id}")
```

## Method 4: Using NoSQL Workbench

1. **Download NoSQL Workbench**: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html
2. **Connect to your AWS account**
3. **Import your table**
4. **Browse and query data visually**
