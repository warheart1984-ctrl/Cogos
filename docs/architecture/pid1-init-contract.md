# CoGOS v11 PID 1 Init Contract

Decision: v11 uses a shell-based PID 1 gatekeeper at
`/opt/cogos/bin/cognitive_init`.

## Why Shell For v11

- The current v10 `cognitive_init` is already a prototype shell script.
- Puppy/Trixie has `/bin/sh` available at the earliest userspace point.
- Shell keeps emergency recovery simple: failure drops directly to `/bin/sh`.
- A compiled PID 1 binary is a later hardening step, not required for v11's
  gatekeeper proof.

## Dependency Boundary

The shell gate owns the first execution contract. Python is not assumed until
after `cognitive_init` checks for it.

If Python is missing:

- native init is not started;
- CoGOS writes a minimal shell proof when possible;
- the system fails closed to maintenance shell.

If Python exists:

- `cogos_boot.py --boot` must pass;
- `cogos_daemon.py --daemon` must start and stay running;
- full PID 1 proof is written to `/opt/cogos/memory/logs/pid1_proof.json`;
- only then does PID 1 `exec /usr/sbin/init.original`.

## Claim Boundary

v11 is a true PID 1 gatekeeper. It is not yet a permanent PID 1 supervisor and
not yet kernel-level pre-process enforcement.
