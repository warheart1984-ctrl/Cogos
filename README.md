# CoGOS

CoGOS is the Project Infi / ARIS governed runtime layer for a Puppy/Trixie
bootable Linux substrate.

Current release: `v11.0.0`

## What v11 Does

v11 is the first true PID 1 gatekeeper release:

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

v11 is a PID 1 gatekeeper, not a permanent PID 1 supervisor and not yet
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
sudo COGOS_WORK=/tmp/project-infi-cogos-full-os-build-v11 \
  bash scripts/build_trixie_cogos.sh "/mnt/e/project-infi/TrixiePup64-Wayland-2601-260502.iso"
```

Expected local output:

```text
AI OS Trixie Build/output/project-infi-aris-trixie-full-os-v11.iso
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
sha256sum project-infi-aris-trixie-full-os-v11.iso > project-infi-aris-trixie-full-os-v11.iso.sha256
```

Published v11 SHA-256:

```text
35e1075b2fd62032f177884d86d82791e2d478ecb472655df8a173aa42cb5a33
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

## Known-Good v11 Proof Flow

```sh
cogos-pid1-proof
cogos-operator
cogos-daemon --verify-laws
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
- `AI OS Trixie Build/payload/opt/cogos/docs/OPERATOR_HANDBOOK.md`
- `release/RELEASE_NOTES_v11.md`
