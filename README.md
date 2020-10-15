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
