#!/bin/bash

set -e

if [ ! -f "deployment-config.txt" ]; then
    echo "❌ deployment-config.txt not found. Nothing to clean up."
    exit 1
fi

source deployment-config.txt

echo "🧹 Cleaning up AWS resources..."
echo "========================================"

# Disable and delete CloudFront distribution if it exists
if [ ! -z "$DISTRIBUTION_ID" ]; then
    echo "📡 Disabling CloudFront distribution: $DISTRIBUTION_ID"
    
    # Get current distribution config
    aws cloudfront get-distribution-config --id $DISTRIBUTION_ID > dist-config.json
    
    # Extract ETag and config
    ETAG=$(jq -r '.ETag' dist-config.json)
    jq '.DistributionConfig | .Enabled = false' dist-config.json > updated-config.json
    
    # Disable distribution
    aws cloudfront update-distribution \
        --id $DISTRIBUTION_ID \
        --distribution-config file://updated-config.json \
        --if-match $ETAG
    
    echo "⏳ CloudFront distribution disabled. Deletion requires manual action after deployment completes."
    echo "   To delete later: aws cloudfront delete-distribution --id $DISTRIBUTION_ID --if-match <new-etag>"
    
    rm -f dist-config.json updated-config.json
fi

# Empty and delete S3 bucket
if [ ! -z "$BUCKET_NAME" ]; then
    echo "🪣 Emptying S3 bucket: $BUCKET_NAME"
    aws s3 rm s3://$BUCKET_NAME --recursive
    
    echo "🗑️ Deleting S3 bucket: $BUCKET_NAME"
    aws s3 rb s3://$BUCKET_NAME
fi

echo ""
echo "✅ Cleanup completed!"
echo "💰 AWS resources have been removed to avoid charges."

# Remove configuration file
rm -f deployment-config.txt