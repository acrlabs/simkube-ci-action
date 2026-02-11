<!--
template: docs.html
-->
# Configuring SimKube CI Action

## `launch-runner` configuration options

| Option | Description | Required
|:---|:---|:---|
| ami-id | AMI ID for SimKube Runner AMI | true |
| instance-type | EC2 instance type | false |
| aws-region | AWS region to launch in | true |
| subnet-id | AWS subnet ID | true |
| security-group-ids | Space separated security group IDs | true |
| runner-labels | Comma separated additional labels for the runner | false |
| simkube-runner-pat | GitHub PAT with repo scope | true |
| aws-access-key-id | AWS access key ID | true |
| aws-secret-acccess-key | AWS secret access key | true |

## `run-simulation` configuration options

| Option | Description | Required
|:---|:---|:---|
| simulation-name | Name of the simulation to run | true |
| trace-path | Path to the trace file | true |
| duration | Simulation duration | false |
| speed | Simulation speed | false |
