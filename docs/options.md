<!--
template: docs.html
-->

# Configuring SimKube CI Action

## `launch-runner` configuration options

| Option                     | Description                                      | Required |
| :------------------------- | :----------------------------------------------- | :------: |
| **ami-id**                 | AMI ID for SimKube Runner AMI                    |    ✅    |
| **instance-type**          | EC2 instance type                                |    ❌    |
| **aws-region**             | AWS region to launch in                          |    ✅    |
| **subnet-id**              | AWS subnet ID                                    |    ✅    |
| **security-group-ids**     | Space separated security group IDs               |    ✅    |
| **runner-labels**          | Comma separated additional labels for the runner |    ❌    |
| **simkube-runner-pat**     | GitHub PAT with repo scope                       |    ✅    |
| **aws-access-key-id**      | AWS access key ID                                |    ✅    |
| **aws-secret-acccess-key** | AWS secret access key                            |    ✅    |

## `run-simulation` configuration options

`run-simulation` exposes a basic set of [skctl](https://simkube.dev/simkube/docs/components/skctl/) options

Implemented features options:

| Option               | Description                   | Required |
| :------------------- | :---------------------------- | :------: |
| **simulation-name**  | Name of the simulation to run |    ✅    |
| **trace-path**       | Path to the trace file        |    ✅    |
| **duration**         | Simulation duration           |    ❌    |
| **driver-image**     | Specify a driver image        |    ❌    |
| **driver-verbosity** | log levels for sk-driver      |    ❌    |
| **speed**            | Simulation speed              |    ❌    |

## Next steps

- [Learn about troubleshooting simkube-ci-action](./troubleshooting.md)
