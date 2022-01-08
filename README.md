# bashrc
Shortcuts / Aliases / Functions for my linux terminal

## AWS

### AWS SSM

#### ssm

Log into a running ec2-instance

> Example Usage
```bash
ssm i-XYZ
```

#### ssm_port

Set port forwarding to ec2-instance

> Example Usage
```bash
ssm_port i-XYZ 8888
```

#### ssm_run

Submit a command to a running ec2-instance

> Example Usage
```bash
echo "sbatch --wrap \"sleep 4\"" | \
ssm_run --instance-id=i-XYZ
```

### AWS SSO

#### aws_sso_<profile>

Log in to AWS profile `<profile>`

> Example Usage
```bash
aws_sso_dev
```


## IAP

Functions related to the Illumina Analytics Platform CLI

### IAP Tokens Management

#### iap_refresh_<WORKGROUP>_session_yaml

Creates a new work token in the workgroup specific session yaml.

### IAP Shortcuts

#### get_iap_aws_sync_command

Takes the input of `iap folders update --with-access --output-format=json`
and returns a AWS s3 sync command with a session token.

> Example Usage
```bash
GDS_PATH="gds://umccr-alexisl-test"
iap folders update "${GDS_PATH}" \
  --with-access \
  --output-format=json | \
get_iap_aws_sync_command \
  --dest "$(mktemp -d)"
```

Yields

```bash
AWS_DEFAULT_REGION="ap-southeast-2" \
AWS_ACCESS_KEY_ID="AB..." \
AWS_SECRET_ACCESS_KEY="CD..." \
AWS_SESSION_TOKEN="EF..." \
shortcuts-aws s3 sync \
  "s3://stratus-gds-aps2/..GH../mini-fastqs/" \
  "/tmp/tmp.s0GX1UXSwu"
```


#### run_illumination_<workgroup>

Runs the illumination docker container in 'detach' mode

> Example Usage

```bash
run_illumination_dev
```

#### run_iap_<workgroup>_gui

Run the PyQt File system gui for iap

> Example Usage
```bash
run_iap_collab_gui gds://umccr-alexisl-test/
```
