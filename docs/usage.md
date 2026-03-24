<!--
template: docs.html
-->

# SimKube CI Action Usage

`simkube-ci-action` is a custom GitHub Action that simplifies running SimKube simulations in your CI pipelines.

## Basics

ACRL publishes two actions that can be included in your workflows:

- **launch-runner** - launches an ephemeral runner in your organization's AWS account and registers it with your repo
- **run-simulation** - runs a simulation on the runner via runs-on tags

While these actions are designed to work together they can be used independently to meet your organizations needs.

## Using **launch-runner**

To use **launch-runner** create a job in your workflow and reference it in the `uses` block:

```yaml
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
```

### AWS credentials

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

A example of an AWS user policy can be found [here](../examples/aws/sk_iam_policy.json).

Once a policy has been added to your user in AWS you can
[create a keypair](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-keys-admin-managed.html#admin-create-access-key).

Your `keypair` should be added to your GitHub Actions Secrets as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

### GitHub Permissions

For `simkube-ci-action` requires access to register runners with your repo. One method of accomplishing this is setting
up a repo scope PAT.

### Example using a fine grained PAT:

#### Setup the PAT in GitHub:

0. Go to user `Settings`
1. Click `Developer settings`
2. Under `Personal access tokens`
3. Choose `Fine-grained tokens`
4. Select the `Resource owner`: if the repo is not owned by you it will send an access request to the owner(s) of the
   repos you select
5. Give the token a descriptive `Token name` and `Description`
6. The `Request message` should give some context to the admin
7. Choose an `Expiration` that meets your organization's policy requirements
8. Select `Only select repositories`
9. Choose the repositories you want to run SimKube in
10. Click `Add permissions`
11. Select Read and Write access for `Actions` and `Administration` Note: `metadata` will be selected by default
12. Click `Generate token and request access`

> [!NOTE] For more on setting up and managing PATs see
> [GitHub's documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

Add the PAT to your repos GitHub Actions Secrets as `AWS_SECRET_ACCESS_KEY`

## Using **run-simulation**

To use **run-simulation** add a job in your workflow and reference it in the `uses` block:

```yaml
jobs:
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

> [!NOTE] The run-simulation action uses `runs-on` tags to target available runners.

## Next steps

- [Learn about simkube-ci-action options](./options.md)
- [Learn about troubleshooting simkube-ci-action](./troubleshooting.md)
