# simkube-ci-action
Automate Simkube simulations as part of your GitHub CI/CD

:construction: Work in progress. :construction:


## Quick Start

### Setup

Add secrets to your GitHub repo:
- `SIMKUBE_RUNNER_PAT` - personal access token with repo scope
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key


### Usage

Create a workflow in the repo with your trace
```yaml
name: Run Simkube Sim

on: [ workflow_dispatch, pull_request ]

jobs:
  test-run:
    uses: ./.github/workflows/run.yml
    with:
      simulation-name: example-simulation
      duration: 5m
      instance-type: c7a.xlarge
      trace-file: ./path/to/your/trace
    secrets: inherit
```
