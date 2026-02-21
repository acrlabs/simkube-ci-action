# simkube-ci-action

Automate Simkube simulations as part of your GitHub CI/CD!

The simkube-ci-action will:

- spin up our custom SimKube Runner AMI in your AWS environment
-

:construction: This action is a work in process alpha. :construction:

## Quick Start

### Setup

Add secrets to your GitHub repo:

- `SIMKUBE_RUNNER_PAT` - personal access token with repo scope
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

### Permissions

The credentials provided need, at a minimum, the following AWS permissions to execute the full workflow in your AWS account:

- ec2:RunInstances
- ec2:CreateTags
- ec2:DescribeInstances
- ec2:DescribeImages

If you are using a trace in S3 the user will need these additional permissions:

- TODO

### Usage

Create a workflow in the repo with your trace

#### Example usage

```yaml
---
name: Run simulation

on: [pull_request]

jobs:
  test-run:
    uses: https://github.com/acrlabs/simkube-ci-action
    with:
      ami-id: ami-0ac57be3bde538a47
      aws-region: us-west-2
      duration: +5m
      instance-type: c7a.xlarge
      security-group-ids: sg-0fd593b495c5e0ffd
      simulation-name: test-sim
      subnet-id: subnet-0cd4625c825e73e61
      trace-path: ./cronjob.sktrace
    secrets:
      SIMKUBE_RUNNER_PAT: ${{ secrets.SIMKUBE_RUNNER_PAT }}
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Development

- TODO
