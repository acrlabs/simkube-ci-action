# simkube-ci-action

Automate SimKube simulations in your CI/CD

For more information on SimKube simulations visit our main [SimKube repo](https://github.com/acrlabs/simkube) or our
documentation at [simkube.dev](https://simkube.dev/).

[Applied Computing Research Labs](https://appliedcomputing.io/) maintains the following actions:

- **launch-runner** - launches an ephemeral runner in your organization's AWS account and registers it with your repo
- **run-simulation** - runs a simulation on the runner via runs-on tags

## Quick Start

### Setup

Add secrets to your GitHub repo:

- `SIMKUBE_RUNNER_PAT` - fine-grained personal access token with repo scope
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

#### GitHub Runner PAT

To use `launch-runner` you will need a Personal Access Token (PAT) scoped to the repo you wish to register the runner
in:

Please see our [usage guide](./docs/usage.md) for a full explanation on how to set up the PAT.

#### AWS credentials

To use `launch-runner` you will need to create a user in AWS with the following permissions:

For managing runners in AWS:

```json
  "Effect": "Allow",
  "Action": [
    "ec2:DescribeImages",
    "ec2:DescribeInstances",
    "ec2:RunInstances",
    "ec2:CreateTags",
  ],
  "Resource": "*"
```

For accessing traces in AWS:

```json
{
  "Effect": "Allow",
  "Action": ["s3:PutObject", "s3:GetObject"],
  "Resource": "arn:aws:s3:::<bucket-name>/*"
}
```

### Usage

For additional information please see our [full usage documentation](./docs/usage.md).

Create a workflow in the repo with your trace

#### Example usage

```yaml
---
name: Run simulation
on:
  workflow_dispatch:
  push:
    branches:
      - "main"
jobs:
  launch-runner:
    runs-on: ubuntu-latest
    steps:
      - name: Setup SimKube GitHub Action runner
        uses: acrlabs/simkube-ci-action/actions/launch-runner@main
        with:
          instance-type: m6a.large
          aws-region: us-west-2
          subnet-id: subnet-xxxx
          security-group-ids: sg-xxxx
          simkube-runner-pat: ${{ secrets.SIMKUBE_RUNNER_PAT }}
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run-simulation:
    needs: launch-runner
    runs-on: [self-hosted, simkube, ephemeral]
    steps:
      - uses: actions/checkout@v5
      - name: Run simulation
        uses: acrlabs/simkube-ci-action/actions/run-simulation@main
        with:
          simulation-name: your-sim-name
          trace-path: path/to/your/trace
```

## How to get support

- open an issue in the [SimKube GitHub repo](https://github.com/acrlabs/simkube/issues)
- message us in the [SimKube Slack Channel](https://kubernetes.slack.com/archives/C07LTUB823Z)
