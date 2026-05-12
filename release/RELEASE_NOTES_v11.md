# CoGOS v11 Release Notes

Release: `project-infi-aris-trixie-full-os-v11.iso`

SHA-256:

```text
35e1075b2fd62032f177884d86d82791e2d478ecb472655df8a173aa42cb5a33
```

## Summary

CoGOS v11 is the first true PID 1 gatekeeper release. The kernel starts
`/opt/cogos/bin/cognitive_init` first; CoGOS verifies law/runtime integrity,
starts the governed daemon, records PID 1 proof, and only then hands off to the
preserved native Puppy/Trixie init.

## Highlights

- True PID 1 gatekeeper path: `kernel -> cognitive_init -> proof -> daemon -> init.original`.
- Fail-closed boot policy: governance boot failure drops to maintenance shell.
- Shell-based PID 1 contract documented for v11.
- `cogos-pid1-proof` command added.
- `cogos-proof` includes `pid1_gate_ok`.
- v10 fast operator behavior preserved after native init handoff.

## Boot Validation

During Hyper-V boot, check the gate phase with:

```sh
tr '\0' ' ' < /proc/1/cmdline
```

The gate-phase command line should identify `cognitive_init`. After successful
handoff, `cogos-pid1-proof` must show `"pid": 1` and `"pid1_gate_ok": true`.

## Claim Boundary

v11 is a true PID 1 gatekeeper, not a permanent PID 1 supervisor. It proves
first-userspace ownership and governed handoff, while full pre-process
kernel-level enforcement remains future work.
