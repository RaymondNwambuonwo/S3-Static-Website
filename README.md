# Static Website on S3

## Overview

Security-themed React application deployed to AWS S3 with CloudFront distribution, demonstrating cloud hosting, CDN setup, and secure static website deployment for DevSecOps and cloud security workflows.

## Purpose

- Deploy React applications to AWS S3 with proper security configurations
- Implement HTTPS delivery and global CDN with CloudFront
- Practice AWS CLI automation for secure deployment pipelines
- Learn cloud security fundamentals (S3 bucket policies, public access controls)

## Tech Stack

- React + TypeScript with Vite (modern frontend build tool)
- AWS S3 (static website hosting with bucket policies)
- AWS CloudFront (CDN and HTTPS termination)
- AWS CLI (deployment automation and infrastructure management)
- Bash scripting (deployment pipeline automation)

## Features

- ✅ Responsive security operations dashboard with real-time clock
- ✅ Mock security metrics (failed logins, SSL certificates, vulnerabilities)
- ✅ Automated S3 deployment with proper security configurations
- ✅ CloudFront CDN setup with HTTPS enforcement
- ✅ Public access controls and CORS policy configuration
- ✅ Optimized caching headers for performance
- ✅ Complete cleanup scripts to avoid AWS charges

## How to Run

```bash
# 1. Create deployment scripts
chmod +x *.sh

# 2. Build and deploy to S3
npm run build
./deploy-to-s3.sh

# 3. Add CloudFront CDN (optional)
./setup-cloudfront.sh

# 4. Test deployment
# Visit the URLs provided in script output

# 5. Clean up when done
./cleanup.sh
```

## Stretch Goals

- [ ] Custom domain with Route 53 DNS and SSL certificate management
- [ ] AWS WAF (Web Application Firewall) integration for additional security
- [ ] Real-time data integration with AWS Lambda and DynamoDB
- [ ] CI/CD pipeline with GitHub Actions for automated deployments
- [ ] Infrastructure as Code using Terraform or CloudFormation
- [ ] Security headers implementation via Lambda@Edge functions

## What I Learned

- AWS S3 static website hosting with bucket policies and public access configuration
- CloudFront CDN setup for global content delivery and HTTPS enforcement
- React application deployment and build optimization for cloud hosting
- AWS CLI automation for Infrastructure as Code and deployment pipelines
- Cloud security fundamentals including CORS policies and access controls
- Cost management strategies with automated resource cleanup procedures
