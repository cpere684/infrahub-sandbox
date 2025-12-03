```markdown
# Infrahub sandbox (extended)

This repository contains an extended developer sandbox image (Dockerfile.infrahub) that bundles a set of commonly used infra/dev tools to provide a ready-to-use environment for developers.

Quick start

1. Build the image:
   docker build -t infrahub-sandbox:latest -f Dockerfile.infrahub .

   Or using docker-compose:
   docker compose build

2. Run a container (mount your workspace and SSH keys):
   docker run --rm -it \
     -v "$(pwd)/workspace":/workspace:rw \
     -v "$HOME/.ssh":/home/dev/.ssh:ro \
     infrahub-sandbox:latest

   Or with compose:
   docker compose up --build -d
   docker compose exec infrahub bash

Where the login warning lives
- The interactive warning printed on shell startup is at /etc/profile.d/sandbox-warning.sh.
- To suppress it locally (not recommended for shared images) create ~/.hushlogin in the mounted home.

Tools installed automatically (by default)

Core system and CLI tooling (apt)
- ca-certificates
- curl
- wget
- gnupg
- lsb-release
- software-properties-common
- git
- unzip, tar
- build-essential (gcc, make, etc.)
- jq (JSON processor)
- vim, nano, less (editors/pagers)
- locales
- procps (ps/top)
- iproute2, iputils-ping, net-tools (networking)
- openssh-client (ssh client)
- sudo

Python and Python-based CLIs (pip)
- python3, python3-pip, python3-venv
- ansible-core (installed via pip)
- awscli (installed via pip)

Kubernetes and cloud infra tools
- kubectl (stable release downloaded from Kubernetes releases)
- helm (Helm v3.x installed via the helm install script)
- terraform (HashiCorp Terraform binary, version controlled by build arg TERRAFORM_VERSION)

Developer utilities and platform CLIs
- gh (GitHub CLI, installed from GitHub's package repo)
- nodejs (installed via NodeSource; major version controlled by NODE_SETUP_VERSION)
- A convenience symlink: /usr/bin/python -> /usr/bin/python3

Optional/conditional installs (enable via build-args)
- Docker CLI (static binary) — enable with --build-arg INSTALL_DOCKERCLI=true
- Go (Golang) runtime — enable with --build-arg INSTALL_GOLANG=true
- You can also override versions at build time:
  - TERRAFORM_VERSION (default set in Dockerfile)
  - HELM_VERSION
  - NODE_SETUP_VERSION
  - and others defined as build args in Dockerfile.infrahub

How to check/verify installed tools inside the container
- ansible:        ansible --version
- awscli:         aws --version
- gh:             gh --version
- kubectl:        kubectl version --client
- helm:           helm version
- terraform:      terraform -version
- node/npm:       node --version && npm --version
- python/pip:     python --version && pip3 --version
- git:            git --version

Examples: build with extras
- Build with Docker CLI included:
  docker build --build-arg INSTALL_DOCKERCLI=true -t infrahub-sandbox:latest -f Dockerfile.infrahub .

- Build with a specific Terraform:
  docker build --build-arg TERRAFORM_VERSION=1.6.0 -t infrahub-sandbox:latest -f Dockerfile.infrahub .

Customization tips & best practices
- Keep the image small: put heavy/rare tools behind build args so devs opt-in.
- Avoid baking secrets: mount ~/.ssh and other secrets at runtime (read-only).
- Run as non-root user (this image defaults to a non-root "dev" user). For stricter isolation, remove passwordless sudo in the Dockerfile.
- If many devs need different toolsets, consider multiple tags/variants: e.g., infrahub-sandbox:base and infrahub-sandbox:infra-full.

Security notes
- This sandbox is for local development/testing only. Treat containers as ephemeral and not a secure storage location for secrets.
- For real credential management, use a secrets manager (Vault, AWS Secrets Manager, etc.) or mount ephemeral credentials at runtime.

```
