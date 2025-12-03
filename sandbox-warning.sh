#!/bin/sh
# /etc/profile.d/sandbox-warning.sh
# POSIX shell; prints a clear warning for interactive shells only and only once per session

case "$-" in
  *i*) ;;
  *) return 0;;
esac

if [ -n "${SANDBOX_WARNING_SHOWN:-}" ]; then
  return 0
fi
export SANDBOX_WARNING_SHOWN=1

cat <<'MSG'

=====================================================================
⚠️  INFRAHUB SANDBOX — DO NOT STORE SECRETS HERE
This container environment is for local development and testing only.
- DO NOT bake or commit private keys, API tokens, or other secrets into the image.
- Mount secret files at runtime (read-only), use test credentials, or a secrets manager.
- Containers are ephemeral and may be accessible from the host; treat them as untrusted.
To suppress this message locally: create ~/.hushlogin (not recommended for shared images).
=====================================================================

MSG
