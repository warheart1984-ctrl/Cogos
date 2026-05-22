# Project Infi / ARIS CoGOS

Project Infi / ARIS CoGOS is a governed AI operating substrate built on a
Debian Cinnamon live image. It inserts a CoGOS governance layer before normal
userspace handoff, records canonical state proofs, and exposes operator tools
for UL/VOSS runtime checks, persistence validation, and ARIS-assisted work.

Current release: `v12.19.0-clean-launch` Wolf CoG OS Clean Launch Edition.

## Wolf CoG OS Clean Launch Feature Set

The current CoGOS line has grown from a persistence proof into a launch-ready
governed OS layer. Major shipped features now include:

- PID 1 cognitive boot gate with law verification, canonical packets, sigil
  binding, guest proof export, and `cogos-pid1-proof`.
- CoGOS runtime spine: GRE/K32 invariants, UL runtime, VOSS proof lane, Nova
  operator surface, Pattern Ledger, deterministic eval harness, and ship
  preflight.
- Automatic and Manual modes: Automatic daily workspace/file suggestions and
  Manual operator controls for ledger, profiles, storage, updates, and UL.
- Control Center and shell surfaces: Operator Dashboard, Governance Timeline,
  LawPulse, Ship Cockpit, file/settings APIs, and the webview shell fallback.
- Install, persistence, recovery, and proof bundles: guarded disk install,
  `COGOSDATA`, recovery verify/rollback, real-hardware proof capture, and
  signed manifests.
- Device and storage governance: HAL inventory, safe mount/unmount, hardware
  veto reporting, storage plans, and RAID proposal-only approval flow.
- Creative and mesh lanes: Story Forge/Beatbox provider hooks, UL package
  catalog, family mesh soak tests, and physical file-drop mesh transport.
- K32 semantic plane: UL/LawPulse/HAL/Automatic routing, kernel-forward daemon,
  and deferred kernel evaluation gates.
- UL App Bridge: governed compatibility membrane for foreign apps using
  OS-assigned sigils, profile policy, error mapping, seccomp v0 spec, and
  hash-chained provenance.
- Wine-Wolf Bridge: governed Windows app launch through Wine with UL handshake,
  bridge daemon, preload shim, default `win.default.safe` profile, and ledgered
  events.
- Windows `.exe` auto-launcher: `.exe` MIME and desktop association route
  double-clicked Windows binaries through `cogos-win-launcher` under the safe
  UL/Wine profile, so users can download and open Windows apps without touching
  Wine settings.

## Release Artifact

The latest local release image is:

```text
AI OS Debian Build/output/project-infi-cogos-12.19.0-clean-launch.iso
```

SHA-256 is written beside the ISO after each local remaster:

```text
AI OS Debian Build/output/project-infi-cogos-12.19.0-clean-launch.iso.sha256
```

The ISO is intentionally ignored by Git because it is roughly 3.9 GB. The repo
tracks build scripts, checksums, architecture docs, and proof artifacts instead.

## What Boots

The Debian image preserves native systemd as `/usr/sbin/init.original` and
places CoGOS first in the boot chain:

```text
kernel -> cognitive_init -> law check -> cogos daemon -> init.original
```

Inside the live system:

```sh
cogos-pid1-proof
cogos-operator
cogos-proof
cogos-ul trace /opt/cogos/examples/ul/hello.ul
cogos-voss proof
cogos-persist
cogos-win-launcher /path/to/app.exe
wolf-wine /path/to/app.exe
cogos-ul-bridge verify-ledger
```

## Proofs

Proof artifacts are tracked under:

```text
AI OS Debian Build/output/proofs/
```

Important proof lanes:

- `guest/` contains baseline boot, PID 1, runtime, eval, and ship preflight
  reports.
- `guest-persistence/` contains persistence-edition proof reports.
- `qemu/` contains VM boot evidence, including `screen.bmp`.
- `*.iso.sha256` files record release checksums without committing the ISOs.

A fresh QEMU boot screenshot for `v12.1.1` is available at:

```text
AI OS Debian Build/output/proofs/qemu/screen.bmp
```

## Governance Stack

- PID 1 law gate before native userspace.
- Canonical state packets under `docs/architecture/`.
- Sigil binding attached to canonical packets.
- Linux Cinnamon host adapter profile.
- UL tracing and VOSS proof commands.
- Ship preflight and guest persistence proof lanes.
- WSL-friendly SquashFS rebuild path using `-no-xattrs` by default.

## Build

Use Linux or WSL with SquashFS and ISO tooling:

```bash
sudo apt-get update
sudo apt-get install -y squashfs-tools xorriso rsync qemu-system-x86
```

Build the Debian CoGOS image:

```bash
cd "AI OS Debian Build"

COGOS_WORK=/tmp/project-infi-debian-cogos-build \
  bash scripts/build_debian_cogos.sh \
  "/mnt/e/project-infi/debian-live-13.4.0-amd64-cinnamon.iso"
```

By default, the build uses `-no-xattrs` for `unsquashfs` and `mksquashfs` so it
works cleanly in unprivileged WSL environments. To preserve SquashFS xattrs on a
host that supports them:

```bash
COGOS_XATTRS=1 \
COGOS_WORK=/tmp/project-infi-debian-cogos-build \
  bash scripts/build_debian_cogos.sh \
  "/mnt/e/project-infi/debian-live-13.4.0-amd64-cinnamon.iso"
```

## VM Boot Test

Run a headless QEMU boot and collect a screen proof:

```bash
COGOS_QEMU_WAIT=120 \
  bash scripts/linux-qemu-screendump-cogos.sh \
  "/mnt/e/project-infi/AI OS Debian Build/output/project-infi-cogos-12.1.1-persistence.iso"
```

The script writes logs and screen captures under:

```text
AI OS Debian Build/output/proofs/qemu/
```

## ARIS Operator Surface

The repo also includes a FastAPI ARIS operator app. It provides a Codex-style
agent surface with:

- chat and agent modes;
- visible plan and tool traces;
- governed file, search, command, and patch tools;
- background job events;
- session export;
- graceful handling when `OPENAI_API_KEY` is not configured.

Run it locally:

```powershell
& "E:\project-infi\AAIS-main\.runtime\python312-store-copy\python.exe" -m uvicorn app.main:app --host 127.0.0.1 --port 8001
```

Then open:

```text
http://127.0.0.1:8001
```

## Key References

- `AI OS Debian Build/README.md`
- `AI OS Debian Build/scripts/build_debian_cogos.sh`
- `scripts/linux-qemu-screendump-cogos.sh`
- `docs/architecture/canonical-state-packet.schema.json`
- `docs/architecture/sigil-binding.md`
- `docs/architecture/host-adapters.md`
- `docs/operator/fast-boot.md`
