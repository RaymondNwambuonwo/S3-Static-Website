#!/bin/bash
set -e

# Configuration
BUCKET_NAME="security-dashboard-$(date +%s)"  # Unique bucket name
REGION="us-east-1"
BUILD_DIR="dist"

echo "🚀 Deploying Static Website to S3"
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "========================================"

# Build the React app
echo "📦 Building React application..."
npm run build

if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ Build directory not found. Make sure 'npm run build' succeeded."
    exit 1
fi

# Create S3 bucket
echo "🪣 Creating S3 bucket: $BUCKET_NAME"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Remove block public access settings for website hosting
echo "🔓 Configuring public access settings for static website..."
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

echo "⏳ Waiting for public access settings to take effect..."
sleep 5

# Configure bucket for static website hosting
echo "🌐 Configuring static website hosting..."
aws s3 website s3://$BUCKET_NAME \
    --index-document index.html \
    --error-document index.html

# Create bucket policy for public read access
echo "🔓 Setting bucket policy for public read access..."
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file://bucket-policy.json

# Configure CORS for security
echo "🛡️ Configuring CORS policy..."
cat > cors-policy.json << EOF
{
    "CORSRules": [
        {
            "AllowedHeaders": ["*"],
            "AllowedMethods": ["GET", "HEAD"],
            "AllowedOrigins": ["*"],
            "ExposeHeaders": [],
            "MaxAgeSeconds": 3000
        }
    ]
}
EOF

aws s3api put-bucket-cors \
    --bucket $BUCKET_NAME \
    --cors-configuration file://cors-policy.json

# Upload files with proper cache headers
echo "📤 Uploading files to S3..."

# Upload HTML files with no-cache headers
aws s3 sync $BUILD_DIR s3://$BUCKET_NAME \
    --exclude "*.js" \
    --exclude "*.css" \
    --exclude "*.map" \
    --cache-control "no-cache, no-store, must-revalidate"

# Upload JS/CSS files with long cache headers
aws s3 sync $BUILD_DIR s3://$BUCKET_NAME \
    --include "*.js" \
    --include "*.css" \
    --exclude "*.map" \
    --cache-control "public, max-age=31536000"

# Upload source maps with no-cache (for debugging)
aws s3 sync $BUILD_DIR s3://$BUCKET_NAME \
    --include "*.map" \
    --cache-control "no-cache"

# Get website URL
WEBSITE_URL="http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Website URL: $WEBSITE_URL"
echo "📁 S3 Bucket: $BUCKET_NAME"
echo ""
echo "📋 Next Steps:"
echo "   1. Visit the website URL to verify deployment"
echo "   2. Run setup-cloudfront.sh to add HTTPS and CDN"
echo "   3. Configure custom domain (optional)"
echo ""

# Save configuration for CloudFront setup
cat > deployment-config.txt << EOF
BUCKET_NAME=$BUCKET_NAME
REGION=$REGION
WEBSITE_URL=$WEBSITE_URL
DEPLOYMENT_DATE=$(date)
EOF

# Cleanup temporary files
rm -f bucket-policy.json cors-policy.json

echo "💾 Configuration saved to deployment-config.txt"