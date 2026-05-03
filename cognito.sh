#!/bin/bash
set -e

POOL_ID="us-east-1_EKlxoavkL"
CLIENT_ID="3l4bg8mk8dhqa2ij7o2biurncm"
EMAIL="testuser@ceedev.co.uk"
PASSWORD="Test@12345"
REGION="us-east-1"

echo "Creating test user..."
aws cognito-idp admin-create-user \
  --user-pool-id "$POOL_ID" \
  --username "$EMAIL" \
  --user-attributes Name=email,Value="$EMAIL" Name=email_verified,Value=true \
  --temporary-password "$PASSWORD" \
  --region "$REGION"

echo "Setting permanent password..."
aws cognito-idp admin-set-user-password \
  --user-pool-id "$POOL_ID" \
  --username "$EMAIL" \
  --password "$PASSWORD" \
  --permanent \
  --region "$REGION"

echo "Done. Test user ready:"
echo "  Email:    $EMAIL"
echo "  Password: $PASSWORD"
