# NEO-DevSecOps
# Ghost CMS Terraform Deployment with Semgrep Security CI

This repository automates the deployment of Ghost CMS on AWS using Terraform. It integrates Semgrep for Terraform security scanning, with Slack notifications to provide real-time scan results during CI runs.

## Features
- Deploys Ghost CMS on an EC2 instance using AWS free tier resources
- Infrastructure managed as code with Terraform
- CI/CD pipeline powered by GitHub Actions
- Security scanning via Semgrep integrated into the pipeline
- Slack alerts for all Semgrep scan findings

## Getting Started

### Prerequisites
- AWS account
- Slack workspace and webhook URL for notifications

### Setup
1. Fork or clone this repo
2. Add required GitHub Secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `SLACK_WEBHOOK_URL`
3. Push changes to `main` branch to trigger deployment pipeline
4. Verify EC2 instance deployment via AWS Console 
5. Check Slack channel for Semgrep scan results

## Possible Improvements

- The setup uses AWS region `eu-north-1` and an EC2 instance type (`t3.micro`) hardcoded in the Terraform files.
- Users should update the `region` and `instance_type` values as needed depending on their preferred AWS region and instance availability.
- To safely run the pipeline multiple times and avoid resource duplication errors, **setting up a remote Terraform state backend using an S3 bucket and DynamoDB table for state locking is recommended**.

## Notes

- Semgrep was successfully integrated and detected 1 finding, which was intentionally left unresolved to confirm the alerting works correctly.


---

