https://zenodo.org/records/20129242
AAIS: A Conceptual Architecture for Governed Cognitive Systems


# CoGOS

CoGOS is the Project Infi / ARIS governed runtime layer for a Puppy/Trixie
bootable Linux substrate.

Current release: `v12.0.0`

## What v12 Does

v12 adds the Universal Language and VOSS execution core as governed local
runtime surfaces while preserving the v11 PID 1 gatekeeper:

```text
kernel -> /opt/cogos/bin/cognitive_init -> law/runtime proof -> cogos daemon -> /usr/sbin/init.original
```

- `cognitive_init` is the first userspace process.
- Native Puppy/Trixie init is preserved as `/usr/sbin/init.original`.
- CoGOS verifies root law and staged runtime files before native handoff.
- CoGOS starts `cogos_daemon.py --daemon` before native handoff.
- CoGOS writes `/opt/cogos/memory/logs/pid1_proof.json`.
- Boot fails closed to maintenance shell if the gate fails.
- Dashboard remains on-demand, preserving v10 fast operator behavior.
- `cogos-ul` runs/traces UL programs and executes UL substrate through ForgeGate.
- `cogos-voss` runs the VOSS golden path, verifier, validation suite, binding demo, and proof.
- `cogos-proof` includes UL/VOSS runtime proof fields.

v12 is still a PID 1 gatekeeper platform, not a permanent PID 1 supervisor and not yet
kernel-level pre-process enforcement.

## Build The ISO

Prerequisites inside Linux or WSL:

```bash
sudo apt-get update
sudo apt-get install -y squashfs-tools xorriso rsync
```

From the repository root:

```bash
cd "AI OS Trixie Build"
sudo COGOS_WORK=/tmp/project-infi-cogos-full-os-build-v12 \
  bash scripts/build_trixie_cogos.sh "/mnt/e/project-infi/TrixiePup64-Wayland-2601-260502.iso"
```

Expected local output:

```text
AI OS Trixie Build/output/project-infi-aris-trixie-full-os-v12.iso
```

The source Trixie/Puppy ISO is not modified.

## Verify The Build

Windows payload check:

```powershell
powershell -ExecutionPolicy Bypass -File "AI OS Trixie Build\scripts\verify_payload.ps1"
```

Checksum the built ISO:

```bash
cd "AI OS Trixie Build/output"
sha256sum project-infi-aris-trixie-full-os-v12.iso > project-infi-aris-trixie-full-os-v12.iso.sha256
```

Published v12 SHA-256:

```text
a95af10ec22f3704a6cb02041388e5040f67159795337e12a107116b8df667fa
```

The repo stores release notes and SHA provenance under `release/`; the ISO
itself is intentionally not committed.

## Run In Hyper-V

From an elevated Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File "E:\project-infi\AI OS Trixie Build\scripts\attach_full_os_hyperv_vm.ps1"
```

If the host cannot allocate fixed 6GB RAM, use a smaller override:

```powershell
powershell -ExecutionPolicy Bypass -File "E:\project-infi\AI OS Trixie Build\scripts\attach_full_os_hyperv_vm.ps1" -MemoryStartupBytes 4GB -ProcessorCount 4
```

## Live PID 1 Check

During the gate phase, confirm the kernel handed first userspace execution to
CoGOS:

```sh
tr '\0' ' ' < /proc/1/cmdline
```

The gate-phase command line should identify `cognitive_init`. After successful
handoff, inspect the proof:

```sh
cogos-pid1-proof
```

It should report `"pid": 1` and `"pid1_gate_ok": true`.

## First Commands Inside The VM

```sh
cogos-pid1-proof
cogos-operator
cogos-perf
cogos-ul trace /opt/cogos/examples/ul/hello.ul
cogos-ul substrate /opt/cogos/examples/ul/safe_substrate.ulsub
cogos-voss proof
cogos-proof
```

Start the dashboard only when needed:

```sh
cogos-dashboard-start
```

Open:

```text
http://localhost:8080
```

Stop the dashboard if the VM feels heavy:

```sh
cogos-dashboard-stop
```

## Known-Good v12 Proof Flow

```sh
cogos-pid1-proof
cogos-operator
cogos-daemon --verify-laws
cogos-ul trace /opt/cogos/examples/ul/hello.ul
cogos-ul substrate /opt/cogos/examples/ul/safe_substrate.ulsub
cogos-voss run-golden
cogos-voss verify-golden
cogos-voss validate
cogos-voss binding-demo
cogos-voss proof
cogos-module admit /opt/cogos/modules/local/trace_analyzer
cogos-module run trace_analyzer
cogos-traits prove
cogos-patterns ingest
cogos-patterns prove
cogos-proof
```

## Docs

- `docs/architecture/pid1-init-contract.md`
- `docs/operator/fast-boot.md`
- `docs/operator/v12-ul-voss.md`
- `docs/runtime/ul-voss-runtime.md`
- `AI OS Trixie Build/payload/opt/cogos/docs/OPERATOR_HANDBOOK.md`
- `release/RELEASE_NOTES_v12.md`
