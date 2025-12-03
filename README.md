```markdown
# Infrahub sandbox (extended)

This repository provides an extended developer sandbox image (Dockerfile.infrahub) that bundles commonly used infra/dev tools so you can start a ready-to-use environment quickly.

This README explains:
- Which tools the image installs by default.
- How to build the image and choose where the image is stored.
- How to choose and mount a workspace directory (so you don't have to leave a workspace folder in the current directory).
- How to run the container and connect to a shell.

---

Quick summary — single developer flow

1. Build the image (example; run with sudo if your user is not in the docker group)
   ```
   docker build -t infrahub-sandbox:latest -f Dockerfile.infrahub .
   ```
   - The trailing `.` is the build context (current directory). See "Build context & where the image is saved" below for alternatives.

2. Start the service with Compose (builds if needed) and run detached
   ```
   docker compose up --build -d
   ```

3. Connect to a shell in the running container
   ```
   docker compose exec infrahub bash
   ```

---

Tools installed automatically (default image)
Core system & CLI
- ca-certificates, curl, wget, gnupg, lsb-release, software-properties-common
- git, unzip, zip, tar, build-essential, jq, vim, nano, less, locales, procps

Python & Python CLIs (installed with pipx for isolation)
- python3, python3-venv, pipx
- ansible-core (via pipx)
- awscli (via pipx)

Kubernetes & cloud infra
- kubectl
- helm
- terraform (version set by build-arg TERRAFORM_VERSION)

Developer & platform tooling
- gh (GitHub CLI)
- nodejs (from NodeSource)
- Optional (build-args): docker CLI static binary, Go toolchain

Networking & runtime helpers
- iproute2, iputils-ping, net-tools
- iptables & nftables (required for Docker host networking)

Verification commands inside the container
- ansible --version
- aws --version
- gh --version
- kubectl version --client
- helm version
- terraform -version
- node --version && npm --version
- python --version && pip3 --version
- git --version

---

Build context & where the image is saved

1) Build context (the `.` at the end of docker build)
- The final argument in `docker build ... .` is the build context. It defines which files are sent to the Docker daemon for use during build.
- To build from a different directory as context, replace `.` with the path to that directory:
  ```
  # Build using /path/to/context as the build context (Dockerfile in current dir)
  docker build -t infrahub-sandbox:latest -f Dockerfile.infrahub /path/to/context
  ```
  or if Dockerfile is inside the context directory:
  ```
  docker build -t infrahub-sandbox:latest /path/to/context
  ```

2) Where the image is stored locally
- By default `docker build -t name:tag` stores the image in the Docker daemon's local image store. The `-t` tag is just a name — it doesn't change storage location.
- If you want to export/save the image to a file (tar) you can use `docker save`:
  ```
  # Save the image as a tarball somewhere else on disk
  docker save -o /path/to/store/infrahub-sandbox-latest.tar infrahub-sandbox:latest
  ```
  - You can move or archive that tarball anywhere (external drive, network share).
  - Load it later on another host with `docker load -i /path/to/infrahub-sandbox-latest.tar`.

3) Push to a registry (preferred for sharing)
- Tag and push to a registry (Docker Hub, GHCR, private registry):
  ```
  docker tag infrahub-sandbox:latest ghcr.io/youruser/infrahub-sandbox:latest
  docker push ghcr.io/youruser/infrahub-sandbox:latest
  ```
- Then other developers can `docker pull ghcr.io/youruser/infrahub-sandbox:latest` and run without building.

---

Choosing the workspace location (don't have to use ./workspace)

- The container expects /workspace inside the image as the workdir. You can mount any host folder into that mount point with `-v` (docker run) or the volumes section in docker compose.

Examples:

1) Mount a workspace in a custom location when running (docker run)
```
docker run --rm -it \
  -v /path/to/your/projects:/workspace:rw \
  -v $HOME/.ssh:/home/dev/.ssh:ro \
  --name infrahub-shell \
  infrahub-sandbox:latest
```

2) Use docker compose and set a custom absolute host path
- Edit docker-compose.yml or use an environment variable (recommended).
- Example compose volume mapping:
  ```
  services:
    infrahub:
      volumes:
        - /path/to/your/projects:/workspace:rw
        - ${HOME}/.ssh:/home/${SANDBOX_USER:-dev}/.ssh:ro
  ```
- Or use a .env file with WORKSPACE_DIR and update compose to reference it:
  ```
  - ${WORKSPACE_DIR:-./workspace}:/workspace:rw
  ```

3) Provide a local .env to avoid typing:
- Create a `.env` file next to docker-compose.yml:
  ```
  WORKSPACE_DIR=/home/you/projects
  LOCAL_UID=1000
  LOCAL_GID=1000
  SANDBOX_USER=dev
  ```
- docker compose will automatically pick up `.env` variables used in docker-compose.yml.

---

Recommended single-command alternatives for convenience

- Build then run and drop into a shell (one-liner)
  ```
  docker build -t infrahub-sandbox:latest -f Dockerfile.infrahub . \
    && docker compose up --build -d \
    && docker compose exec infrahub bash
  ```

- If you prefer not to build locally each time, publish the image to a registry and change docker-compose.yml to use the image: key (remove the build: block). Then `docker compose up -d` will just pull the image.

---

Tips and best practices

- Use a local .env or generate it (generate-env.sh) to set LOCAL_UID/LOCAL_GID and WORKSPACE_DIR so file ownership and mounts match your host user.
- If you mount $HOME/.ssh into the container, be sure the container user is the same mapped user (or adjust the target path).
- Add `.env` to .gitignore to avoid committing local paths or UID/GID.
- If a build fails due to UID/GID collisions, the Dockerfile contains robust logic to pick a free UID/GID automatically. You can still override with build-args:
  ```
  docker build --build-arg UID=2000 --build-arg GID=2000 -t infrahub-sandbox:latest -f Dockerfile.infrahub .
  ```

---

Troubleshooting

- If container exits immediately after `docker compose up -d`:
  - Check logs: `docker compose logs -f infrahub`
  - Check `docker compose ps` for container status.
  - If the container was started without `tty: true`, a bash CMD might exit; run with `tty: true` in compose or run `tail -f /dev/null` as the command.

- To change the build context or Dockerfile path:
  ```
  docker build -t infrahub-sandbox:latest -f path/to/Dockerfile.infrahub path/to/context
  ```

- Save the image for offline use or to export to another host:
  ```
  docker save -o /path/to/store/infrahub-sandbox.tar infrahub-sandbox:latest
  docker load -i /path/to/store/infrahub-sandbox.tar
  ```

---

```
