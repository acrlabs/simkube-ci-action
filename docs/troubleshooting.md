<!--
template: docs.html
-->

# Troubleshooting

This section covers common issues when running simulations both in custom configurations and in CI.

Most problems fall into one of the following categories:

0. Authentication & Permissions Issues
1. AMI availability
2. Simulation startup failures
3. Simulation runtime failures
4. Misconfiguration
5. CI Specific failures

---

## Quick Diagnosis

| Symptom                    | Likely Cause                  |
| :------------------------- | :---------------------------- |
| AMI not found              | Not subscribed / wrong region |
| Fails immediately          | Credentials or permissions    |
| Starts then crashes        | Driver issue                  |
| Missing file errors        | Hooks or trace files          |
| Works locally, fails in CI | Env/config mismatch           |

---

## 0.0 Authentication & Permissions Issues

### Symptoms

- CI jobs fail early, before the simulation starts
- Errors pulling repos, images or artifacts
- AWS API calls fail (e.g. launching EC2 instances)

The user should investigate these potential causes:

### GitHub PAT Issues

- Missing or expired Personal Access Token (PAT)
- Insufficient PAT scope
- Token not correctly injected into CI

#### Checks

- Verify PAT is set in the repo secrets as `$SIMKUBE_RUNNER_PAT`
- Confirm scopes:
  - Repo scope with Read and Write access to `Actions` and `Administration`
  - `Metadata` is included by default
- Try a using a git action using your PAT

  ```sh
  git ls-remote https://github.com/org/repo.git
  ```

#### Fixes

- Regenerate PAT with correct scopes
- In the repo calling the action Ensure token is configured in GitHub Actions
  - `Settings` -> `Secrets and variables` -> `Actions`

---

## 0.1 AWS Credentials Issues

### Common Causes

- Missing or expired credentials
- Incorrect IAM permissions

### Checks

Manual testing:

```sh
aws sts get-caller-identity
```

### Check permissions:

For example `launch-runner` requires at a minimum

- ec2:RunInstances
- ec2:DescribeImages
- ec2:DescribeInstances

### Fixes

- Update IAM role/policy
- Ensure CI is using the correct user/role

---

## 1.0 AMI Not Found / Not Accessible

### Symptoms

- `InvalidAMIID.NotFound`
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
- Confirm you're using the correct region + AMI ID combination
- Verify AMI ID

---

## 2.0 Simulation Fails to Start

This group of issues is usually related to configuration.

## 2.1 Driver Crashes

### Symptoms

- Simulation starts but exits very quickly
- Simulation starts but fails to complete
- Logs show driver errors or panics

### Checks

- Inspect driver logs
- Verify driver image, we recommend using the default driver wherever possible

### Common Causes

- Incompatible driver version
- Invalid configuration passed to driver (the most common cause)
- Missing AMI dependencies (if not using the ACRL SimKube AMIs)

## 2.2 Missing Configuration Files

A default set of hooks is provided in the `run-simulation` CI action. This should issue is only common in custom
configurations, not in `simkube-ci-action`.

### Symptoms

- Simulation fails to start
- Trace path errors

### Checks

- Simulation requires a [hooks configuration file](https://simkube.dev/simkube/docs/adv/hooks/)
- Simulation requires a [trace artifact](https://simkube.dev/simkube/docs/adv/traces/) to replay
- Check paths to resources

### Fixes

- Create or update a hooks configuration
- Create or update trace and/or trace path

---

## 3.0 Simulation Runtime Issues

## Symptoms

- Simulation starts but fails
- Simulation starts but never finishes

## Checks

- Check system resources of the machine you are running on
- Review simulation logs

## Fixes

- Increase instance size
- Validate configuration parameters

---

## 4.0 Misconfiguration

This is a catch-all and is the most common root cause of simulation failures.

### Common Issues

- Incorrect file paths
- Wrong CLI flags
- Mismatched versions (Driver & AMI incompatibility)
- Missing environment variables

---

## 5.0 CI Specific Issues

### Symptoms

- Configuration works locally and/or remotely but fails in CI

### Common Causes

- Missing secrets
- Missing environment variables

---

## Still stuck, how can I get support?

- open an issue in the [SimKube GitHub repo](https://github.com/acrlabs/simkube/issues)
- message us in the [SimKube Slack Channel](https://kubernetes.slack.com/archives/C07LTUB823Z)
