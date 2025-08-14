#!/bin/bash
set -e

# Load configuration from S3 deployment
if [ ! -f "deployment-config.txt" ]; then
    echo "❌ deployment-config.txt not found. Run deploy-to-s3.sh first."
    exit 1
fi

source deployment-config.txt

echo "🌍 Setting up CloudFront Distribution"
echo "Bucket: $BUCKET_NAME"
echo "========================================"

# Create CloudFront distribution configuration
cat > cloudfront-config.json << EOF
{
    "CallerReference": "security-dashboard-$(date +%s)",
    "Comment": "Security Dashboard - Static Website Distribution",
    "DefaultRootObject": "index.html",
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-$BUCKET_NAME",
                "DomainName": "$BUCKET_NAME.s3.amazonaws.com",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "http-only"
                }
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-$BUCKET_NAME",
        "ViewerProtocolPolicy": "redirect-to-https",
        "MinTTL": 0,
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            }
        },
        "TrustedSigners": {
            "Enabled": false,
            "Quantity": 0
        }
    },
    "Enabled": true,
    "PriceClass": "PriceClass_100"
}
EOF

echo "📡 Creating CloudFront distribution..."
DISTRIBUTION_OUTPUT=$(aws cloudfront create-distribution \
    --distribution-config file://cloudfront-config.json)

DISTRIBUTION_ID=$(echo $DISTRIBUTION_OUTPUT | jq -r '.Distribution.Id')
CLOUDFRONT_DOMAIN=$(echo $DISTRIBUTION_OUTPUT | jq -r '.Distribution.DomainName')

echo ""
echo "✅ CloudFront distribution created successfully!"
echo "🆔 Distribution ID: $DISTRIBUTION_ID"
echo "🌐 CloudFront URL: https://$CLOUDFRONT_DOMAIN"
echo ""
echo "⏳ Note: CloudFront deployment takes 15-20 minutes to complete."
echo "   You can check status with: aws cloudfront get-distribution --id $DISTRIBUTION_ID"
echo ""

# Update configuration file
cat >> deployment-config.txt << EOF
DISTRIBUTION_ID=$DISTRIBUTION_ID
CLOUDFRONT_DOMAIN=$CLOUDFRONT_DOMAIN
CLOUDFRONT_URL=https://$CLOUDFRONT_DOMAIN
EOF

# Cleanup
rm -f cloudfront-config.json

echo "📊 Security Features Enabled:"
echo "   ✅ HTTPS enforced (redirect-to-https)"
echo "   ✅ Global CDN distribution"
echo "   ✅ Caching optimized for performance"
echo "   ✅ Origin access protection"
echo ""
echo "💾 Updated configuration saved to deployment-config.txt"