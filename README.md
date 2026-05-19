# CoGOS - Project Infi Cognitive OS

CoGOS is the Project Infi / ARIS governed cognitive OS image.

It remasters Debian Live into a bootable operator system with a law-gated
runtime, Nova operator surface, UL substrate, signed manifests, recovery mode,
safe storage controls, and a real installer path.

## Current Release

**Release:** `12.10.1-hardware-boot`

This release fixes the real-hardware boot freeze risk by making the PID1
governance gate fast and hardware-safe:

- PID1 performs a bounded law/proof check.
- Long-running HAL, determinism, daemon, and UI work is deferred to init.
- Native Debian init receives control quickly.
- Kernel bypass flags are available for target-laptop recovery.

Local ISO:

```text
AI OS Debian Build/output/project-infi-cogos-12.10.1-hardware-boot.iso
```

SHA256:

```text
ada0e437802c4f79ef7d77eeda09d8243d4f087923922c6caf78bcbc88ff2671
```

The ISO binary is not stored in Git because it is about 3.9 GB. The checksum
and source payload are tracked so the image can be verified and rebuilt.

## What Is Included

- Governed PID1 boot gate with native Debian handoff
- CoGOS runtime spine: GRE, Nova, UL, VOSS, Pattern Ledger
- CoGOS Control Center
- First-run wizard
- Automatic mode for workspaces, file organization, memory, and workflow hints
- UL stdlib v0.1 with examples
- Device + Storage Manager MVP
- Safe mount/unmount path for removable storage
- Signed release, package, and update manifests
- Recovery mode: verify, rollback, backup restore, first-run reset
- Guarded full-disk installer
- Persistence support
- Ship preflight and smoke tests

## Hardware Boot Notes

Use the `12.10.1-hardware-boot` ISO for the HP target laptop.

If the laptop freezes at the Debian splash, edit the boot entry and add:

```text
cogos.safe=1
```

That bypasses the CoGOS PID1 gate and hands directly to Debian native init.
If Debian boots with `cogos.safe=1`, the base image and hardware path are good.

For strict fail-closed proof mode:

```text
cogos.pid1.strict=1
```

For full early PID1 checks:

```text
cogos.pid1.full=1
```

For recovery mode:

```text
cogos.recovery=1
```

## Build The ISO

From WSL/Linux:

```bash
cd "AI OS Debian Build"
COGOS_WORK=/tmp/project-infi-cogos-build \
COGOS_OUT="$PWD/output/project-infi-cogos-12.10.1-hardware-boot.iso" \
  bash scripts/build_debian_cogos.sh \
  "/mnt/e/project-infi/debian-live-13.4.0-amd64-cinnamon.iso"
```

The work directory must be on a Linux filesystem, not an NTFS mount, because
the Debian ISO contains symlinks and Unix metadata.

## Validate Before Remaster

From Windows PowerShell:

```powershell
$env:COGOS_ROOT = "E:\project-infi\AI OS Trixie Build\payload\opt\cogos"
$py = "E:\project-infi\AAIS-main\.runtime\python312-store-copy\python.exe"
& $py "$env:COGOS_ROOT\bin\cogos_ship.py" preflight
```

Expected:

```text
CoGOS ship preflight: READY_TO_REMASTER
PASS phase_eval: 15/15
PASS signed_manifests
```

## Useful Live Commands

```bash
cogos-ship preflight
cogos-pid1-proof
cogos-recovery status
cogos-recovery verify
cogos-first-run status
cogos-desktop-start
cogos-device-storage status
cogos-install plan --target /dev/sdX
```

## Flashing

Use Rufus or another raw-image writer on Windows.

Recommended Rufus mode:

```text
DD/image mode
```

## Repository Layout

```text
AI OS Trixie Build/payload/opt/cogos/   CoGOS runtime, config, docs, examples
AI OS Trixie Build/payload/usr/local/bin/ Live ISO command wrappers
AI OS Debian Build/scripts/             Debian remaster script
AI OS Debian Build/output/*.sha256      Published ISO checksums
scripts/                                Host-side smoke/remaster/QEMU helpers
```

## License

Apache License 2.0. See `LICENSE`.

## Author

Jon Halstead  
@warheart1984-ctrl
