<!--
template: docs.html
-->

# Troubleshooting

## General simkube-ci-action Debugging

If you are running `simkube-ci-action` and experiencing failures please review the common issues below. Inspect the
GitHub Action logs for for specific error messages to reference below for both the
[launch-runner](#launch-runner-issues) and [run-simulation](#run-simulation-issues) custom actions. If you are
experiencing issues on the runner it can be helpful to temporarily set [keep-alive](#keep-runner-alive) on the runner to
prevent auto-termination.

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
          instance-type: m6a.large
          aws-region: us-west-2
          subnet-id: subnet-xxxx
          security-group-ids: sg-xxxx
          simkube-runner-pat: ${{ secrets.SIMKUBE_RUNNER_PAT }}
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          keep-alive: true  # Turn on keep-alive by adding it here
```

> [!WARNING] When using `keep-alive` be sure to manually delete your EC2 instance when you are done debugging as it
> **will not** self-terminate!

To connect to your runner first push an SSH key to it using `ec2-instance-connect`:

```sh
aws ec2-instance-connect send-ssh-public-key \
  --instance-id <instance-id> \
  --region <region> \
  --instance-os-user ubuntu \
  --ssh-public-key file://~/path/to/your/public/key.pub \
  --profile <your-profile>
```

> [!NOTE]
> [send-ssh-public-key](https://docs.aws.amazon.com/ec2-instance-connect/latest/APIReference/API_SendSSHPublicKey.html)
> creates a temporary key that lasts for 60 seconds so connect via SSH directly after sending your key.

Connect to the instance via SSH:

```sh
ssh ubuntu@<instance-public-ip>
```

If you see "Permission Denied" re-run the `ec2-instance-connect` command above and SSH into them directly after. Your
key is stored temporarily, it will expire after 60 seconds.

---

## Launch Runner Issues

Typically issues related to the `launch-runner` action will exit the step with a non-zero exit code. The runner does not
launch in EC2 and the workflow will not proceed to the `run-simulation` step. For clues look for the specific error
messages in the `launch-runner` GitHub Action logs. Use the sections below to address the specific error messages.

### Invalid AMI

- `InvalidAMIID.Malformed` - indicates a malformed AMI ID
- `InvalidAMIID.NotFound` - indicates the AMI is invalid or is not accessible

Marketplace AMIs must be subscribed via Marketplace to to be visible. Confirm you're using the correct region + AMI ID
combination (AMI IDs are region specific identifiers). To check AMI visibility test your AMI & region combination:

```sh
aws ec2 describe-images --image-ids <ami-id> --region <region>
```

### AWS AuthFailure

`AuthFailure` means the provided AWS access credentials were invalid. Check the correct secrets are being passed to
`aws-access-key-id` and `aws-secret-access-key`. See [Usage](./usage.md#aws-credentials) for required AWS secrets.

### AWS UnauthorizedOperation & AccessDenied

`UnauthorizedOperation` and `AccessDenied` errors indicate that the role specified is valid but does not have sufficient
permissions to perform the action. See [Usage](./usage.md#aws-credentials) for permissions or our
[example IAM policy](/simkube/docs/ref/aws_iam_policy/)

### GitHub PAT Issues

`Bad credentials` or `Failed to generate runner token` during the `Setup SimKube GitHub Action runner` step all indicate
issues with the GitHub PAT. Expired PATs, insufficient PAT scope, and invalid PATs will all produce these errors. Ensure
the repo calling the action has the PAT secret configured correctly as `$SIMKUBE_RUNNER_PAT`, the PAT is unexpired and
has sufficient scope. Details on how to setup the PAT can be found in the [Usage](./usage.md#setup-a-pat-in-github)
documentation. Additional documentation GitHub PATs
[here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

---

## Run Simulation Issues

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

For `simkube-ci-action` we recommend you use the default driver by not specifying one in `run-simulation`. If you
specify an incompatible driver version `sk-driver` will fail to start or fail mid-replay.

### Hook File Errors

SimKube requires a hooks file to run the simulation. `run-simulation` uses a default
[hooks configuration file](https://simkube.dev/simkube/docs/adv/hooks/).

If you are running custom hooks and seeing "Error: error reading hook path/to/your/hooks", the hook file was not found.
Check the path to your hooks file:

```sh
ls path/to/your/hooks
```

### Trace File Errors

Simulation requires a [trace artifact](https://simkube.dev/simkube/docs/adv/traces/) to replay.

#### Trace File Not Found

If simulation fails with the message "ERROR: Trace file not found" in incorrect file path was specified. For more
information on traces visit the [traces section](https://simkube.dev/simkube/docs/adv/traces/) on the docs. Check the
path to your trace and ensure it is a valid trace file:

```sh
ls path/to/your/trace
```

#### Could Not Parse Trace File

"Error: could not parse trace file", the trace file path specified is invalid. Validate your trace.

You can validate your trace file by using the [skctl](https://simkube.dev/simkube/docs/components/skctl/) CLI utility:

```sh
skctl validate check path/to/your/trace
```

Any trace validation errors will be listed. If the list is empty your trace artifact is ready for replay.

---

## Still stuck, how can I get support?

- open an issue in the [SimKube GitHub repo](https://github.com/acrlabs/simkube/issues)
- message us in the [SimKube Slack Channel](https://kubernetes.slack.com/archives/C07LTUB823Z)
- contact us [directly](https://appliedcomputing.io/contact)
