<!--
template: docs.html
-->

# Troubleshooting

## General simkube-ci-action Debugging

Check the failure output

### Keep Runner Alive

Set `keep-alive` to true in `launch-runner` action. This will keep the runner alive after the job completes regardless
of if the job succeeds or fails:

```sh
jobs:
  launch-runner:
    runs-on: ubuntu-latest
    steps:
      - name: Setup SimKube GitHub Action runner
        uses: acrlabs/simkube-ci-action/actions/launch-runner@main
        with:
          ami-id: ami-example
          instance-type: m6a.large
          aws-region: us-west-2
          subnet-id: subnet-example
          security-group-ids: sg-example
          simkube-runner-pat: ${{ secrets.SIMKUBE_RUNNER_PAT }}
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          keep-alive: true  # Turn on keep-alive by adding it here
```

> [!NOTE] When using `keep-alive` be sure to manually delete your EC2 instance when you are done debugging as it **will
> not** self-terminate!

---

## Launch Runner Issues

Typically issues related to the `launch-runner` action will exit the step with a non-zero exit code. The runner does not
launch in EC2 and the workflow will not proceed to the `run-simulation` step. For clues look for the specific error
messages in the `launch-runner` GitHub Action logs. Use the sections below to address the specific error messages.

### Invalid AMI

- `InvalidAMIID.Malformed` - indicates a malformed AMI ID
- `InvalidAMIID.NotFound` - indicates the AMI is invalid or is not accessible

Marketplace AMIs must be subscribed via Marketplace to to be visible. Make sure the correct region is selected, AMIs are
region specific. To check AMI visibility test your ami & region combination:

```sh
aws ec2 describe-images --image-ids <ami-id> --region <region>
```

### AWS AuthFailure

`AuthFailure` means the AWS access credentials were invalid. Check the correct secrets are being passed to
`aws-access-key-id` and `aws-secret-access-key`. See [Usage](./usage.md) for required AWS secrets.

### AWS UnauthorizedOperation & AccessDenied

`UnauthorizedOperation` and `AccessDenied` errors indicate that the role specified is valid but does not have sufficient
permissions to perform the action. See [Usage](./usage.md) for permissions or our
[example IAM policy](../examples/aws/sk_iam_policy.json)

### GitHub PAT Issues

`Bad credentials` or `Failed to generate runner token` during the `Setup SimKube GitHub Action runner` step. All
indicate issues with the GitHub PAT. Expired PATs, insufficient PAT scope, and invalid PATs will all produce these
errors. Ensure the repo calling the action has the PAT secret configured correctly as `$SIMKUBE_RUNNER_PAT`, the PAT is
unexpired and has sufficient scope. Details on how to setup the PAT can be found in the [Usage](./usage.md)
documentation.

---

## Run Simulation Errors

Runner launches and registers but `run-simulation` fails with a non-zero exit code. A failure summary will appear in the
`run-simulation` GitHub Action logs that dumps some cluster state and common debugging aids which can be expanded to see
the output. The failure summary includes the following sections:

- Simulation Status
- Simulation YAML
- sk-ctrl logs
- sk-driver logs
- All nodes in the simkube namespace
- All pods in the simkube namespace
- Recent events (tail=20)
- Get all

### Incompatible Driver Versions

### Hook File Errors

### Trace File Errors

#### Trace File Not Found

If simulation fails with the message "ERROR: Trace file not found" in incorrect file path was specified. For more
information on traces visit the [traces section](https://simkube.dev/simkube/docs/adv/traces/) on the docs. Check the
path to your trace and ensure it is a valid trace file:

```sh
  ls path/to/your/trace
```

#### Could Not Parse Trace File

"Error: could not parse trace file", the trace file path specified is invalid. Validate your trace.

You can validate your trace file by using the `skctl` CLI utility:

```sh
  skctl validate check path/to/your/trace
```

## 1.0 Authentication & Permissions Issues

### Symptoms

- CI jobs fail early, before the simulation starts
- Errors pulling repos, images or artifacts
- AWS API calls fail (e.g. launching EC2 instances)

Investigate these potential causes:

## 1.1 GitHub PAT Issues

- Missing or expired Personal Access Token (PAT)
- Insufficient PAT scope
- Token not correctly injected into CI

### Checks

- Verify PAT is set in the repo secrets as `$SIMKUBE_RUNNER_PAT`
- Confirm scopes:
  - Repo scope with Read and Write access to `Actions` and `Administration`
- In the repo calling the action Ensure PAT is added as a Secret in GitHub
  - `Settings` -> `Secrets and variables` -> `Actions`

### Reference docs

- [Usage guide](./usage.md) for how to set up PATs
- [GitHub PAT documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
  for additional documentation

---

## 1.2 AWS Credentials Issues

### Common Causes

- Missing or expired credentials
- Incorrect IAM permissions

### Checks

Manual testing:

```sh
aws sts get-caller-identity
```

### Check permissions:

For example `launch-runner` requires at a minimum:

- ec2:RunInstances
- ec2:DescribeImages
- ec2:DescribeInstances

See [Usage](./usage.md) for full permissions or our [example IAM policy](../examples/aws/sk_iam_policy.json)

### Fixes

- Update IAM role/policy
- Ensure CI is using the correct user/role

---

## 2.0 AMI Not Found / Not Accessible

### Symptoms

- `InvalidAMIID.NotFound` errors
- AMI not visible in console
- launch fails immediately

### Common causes

- Custom AMIs require subscription (via Marketplace) or they will not be selectable
- Wrong region
- AMI ID is outdated or deleted

### Checks

Verify AMI is visible:

```sh
aws ec2 describe-images --image-ids <ami-id> --region <region>
```

### Fixes

- Ensure your organization has subscribed to the AMI product
- Confirm you're using the correct region + AMI ID combination (AMI IDs are region specific identifiers)
- Verify AMI ID, we recommend using our safe default whenever possible

---

## 3.0 Simulation Fails to Start

This group of issues is usually related to SimKube configuration files.

## 3.1 Driver Crashes

### Symptoms

- Simulation starts but exits very quickly
- Simulation starts but fails to complete
- Logs show driver errors or panics

### Checks

- Inspect driver logs
- Verify driver image

### Common Causes

- Incompatible driver version
- Invalid configuration passed to driver
- Missing AMI dependencies (if not using the ACRL SimKube AMIs)

### Fixes

- We include some status and minimal logs in the failure summary section of the action output, this will be visible if
  `run-simulation` returns a non-zero exit code
- In CI, set `keep-alive` option in the `launch-runner` and SSH into the instance and inspect the detailed logs

> [!NOTE] When using `keep-alive` be sure to manually delete your EC2 instance as it **will not** self-terminate!

## 3.2 Missing Configuration Files

A default set of hooks is provided in the `run-simulation` CI action. This issue is most common to custom
configurations, not in CI using `simkube-ci-action`.

### Symptoms

- Simulation fails to start
- Trace path errors

### Checks

- Simulation requires a [hooks configuration file](https://simkube.dev/simkube/docs/adv/hooks/)
  - check the path to your hooks

    ```sh
    ls path/to/your/hooks
    ```

- Simulation requires a [trace artifact](https://simkube.dev/simkube/docs/adv/traces/) to replay
  - check the path to your trace

  ```sh
  ls path/to/your/trace
  ```

### Fixes

- Create or update a hooks configuration
- Create or update trace and/or trace path

---

## 4.0 Simulation Runtime Issues

## Symptoms

- Simulation starts but fails
- Simulation starts but never finishes

## Checks

- Check system resource utilization:
  - Set `keep-alive` on `launch-runner` if running in CI
  - SSH into the instance
  - View resource utilization

    ```sh
    top
    ```

- Review simulation logs
  - pod logs of driver

    ```sh
    kubectl logs <driver-pod-name>
    ```

## Fixes

- Increase instance size or change instance type to meet your simulation needs
- Validate configuration parameters

---

## 5.0 Misconfiguration

This is a catch-all and is the most common root cause of simulation failures.

### Common Issues

- Incorrect file paths
- Missing or incorrect CLI flags
- Mismatched versions (Driver & AMI incompatibility)

### Checks

- Check all path names
- Review all CLI flags and/or GitHub Action input fields
- Review Driver & AMI versions to ensure compatibility

---

## 6.0 CI Specific Issues

### Symptoms

- Configuration works locally and/or remotely but fails in CI

### Common Causes

- Missing or incorrect secrets
- Missing or incorrect inputs

See [Usage](./usage.md) and [Options](./options.md) pages for more on secrets and inputs.

### Fixes

- Add or update secrets
- Add or update inputs

---

## Still stuck, how can I get support?

- open an issue in the [SimKube GitHub repo](https://github.com/acrlabs/simkube/issues)
- message us in the [SimKube Slack Channel](https://kubernetes.slack.com/archives/C07LTUB823Z)
