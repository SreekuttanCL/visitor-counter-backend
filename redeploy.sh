#!/bin/bash
set -e

echo "🚀 Starting visitor counter redeploy..."

# 1. Zip Lambda
echo "📦 Zipping Lambda..."
cd backend/lambda
rm -f ../deployment.zip
zip -r ../deployment.zip app.py
cd ..

# 2. Terraform apply (Lambda + API Gateway)
echo "🧱 Running Terraform apply..."
cd terraform
terraform apply -auto-approve
cd ../..

# 3. OPTIONAL: CloudFront cache invalidation
# Uncomment if you are using CloudFront
# echo "🌍 Invalidating CloudFront cache..."
# aws cloudfront create-invalidation \
#   --distribution-id YOUR_DISTRIBUTION_ID \
#   --paths "/*"

echo "✅ Redeploy complete!"

