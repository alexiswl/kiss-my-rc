# bashrc
Shortcuts / Aliases / Functions for my MacOS/WSL2/Linux terminal(s)

## Setup

### Requirements

* aws (v2)
* bash (4.3+)
* jq (v1.6)
* modules (4+)

### Setting your bashrc / zshrc

Simply clone this repo and then add the following line to your `~/.bashrc`

```bash
source "/path/to/repos/bashrc/profiles/WSL2Profile.bash"
```

## Modules

### my-aws-shortcuts/1.0.0

#### ssm

> Autocompletion-enabled: :greentickmark:

Log into a running ec2-instance

> Example Usage
```bash
ssm i-XYZ
```

Example: :construction:

#### ssm_port

> Autocompletion-enabled: :greentickmark:

Set port forwarding to ec2-instance

> Example Usage
```bash
ssm_port i-XYZ 8888
```

Example: :construction:

#### ssm_run

> Autocompletion-enabled: :greentickmark:

Submit a command to a running ec2-instance

> Example Usage
```bash
echo "sbatch --wrap \"sleep 4\"" | \
ssm_run --instance-id=i-XYZ
```

### Local Path Shortcuts

#### go_to_git/1.0.0

> Autocompletion-enabled: :greentickmark:

Searches `"$GITHUB_PATH"` for git repositories. 

Example: :construction:

## Troubleshooting

This GitHub repo uses soft-links that may 
not be compatible with Windows WSL2 Users. 

I will write up a guide on how to seamlessly 
use soft-links with Git / WSL2 and Windows at a later date.



