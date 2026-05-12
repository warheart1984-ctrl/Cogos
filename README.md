# CoGOS

CoGOS is the Project Infi / ARIS governed runtime layer for a Puppy/Trixie
bootable Linux substrate. The v10 release focuses on Fast Operator Boot: the VM
starts into a lightweight operator path first, with the dashboard and desktop
available on demand.

Current release: `v10.0.0`

## What v10 Does

- Fast operator boot with `/opt/cogos/config/boot_profile.json`.
- Dashboard is on-demand, not an automatic boot cost.
- Hyper-V helpers default to 4 CPUs and fixed 6GB startup memory.
- Governance stack unchanged from v9: law engine, sandboxed modules, Trait
  Identity Runtime, Pattern Ledger, immune recommendations, and proof flow.

## Build The ISO

Prerequisites inside Linux or WSL:

```bash
sudo apt-get update
sudo apt-get install -y squashfs-tools xorriso rsync
```

From the repository root:

```bash
cd "AI OS Trixie Build"
sudo COGOS_WORK=/tmp/project-infi-cogos-full-os-build-v10 \
  bash scripts/build_trixie_cogos.sh "/mnt/e/project-infi/TrixiePup64-Wayland-2601-260502.iso"
```

Expected local output:

```text
AI OS Trixie Build/output/project-infi-aris-trixie-full-os-v10.iso
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
sha256sum project-infi-aris-trixie-full-os-v10.iso > project-infi-aris-trixie-full-os-v10.iso.sha256
```

Published v10 SHA-256:

```text
48a3d6dbb87150cadc033cec9167e714afe802bc3cf86d5385033ce2f215c8a8
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

Tune an existing VM:

```powershell
powershell -ExecutionPolicy Bypass -File "E:\project-infi\AI OS Trixie Build\scripts\tune_hyperv_vm.ps1"
```

## First Commands Inside The VM

Open a terminal in Puppy/Trixie and run:

```sh
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

Desktop guidance:

```sh
cogos-desktop-hint
```

## Known-Good v10 Proof Flow

```sh
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

- `docs/operator/fast-boot.md`
- `AI OS Trixie Build/payload/opt/cogos/docs/OPERATOR_HANDBOOK.md`
- `release/RELEASE_NOTES_v10.md`

