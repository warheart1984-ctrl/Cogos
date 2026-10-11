#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/build_trixie_cogos.sh /path/to/TrixiePup64-Wayland-2601-260502.iso

Output:
  output/project-infi-aris-trixie-full-os-v12.iso

Required Linux tools:
  unsquashfs mksquashfs xorriso rsync
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if [[ $# -ne 1 ]]; then
  usage >&2
  exit 1
fi

ISO="$(readlink -f "$1")"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${COGOS_WORK:-$ROOT/work}"
OUT="${COGOS_OUT:-$ROOT/output/project-infi-aris-trixie-full-os-v12.iso}"
PAYLOAD="$ROOT/payload"

for tool in unsquashfs mksquashfs xorriso rsync find; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "Missing required tool: $tool" >&2
    exit 2
  }
done

if [[ ! -f "$ISO" ]]; then
  echo "ISO not found: $ISO" >&2
  exit 3
fi

rm -rf "$WORK"
mkdir -p "$WORK/iso" "$WORK/rootfs" "$ROOT/output"

echo "[1/7] Extract ISO contents"
xorriso -osirrox on -indev "$ISO" -extract / "$WORK/iso" >/dev/null

echo "[2/7] Locate SquashFS"
SFS_SOURCE="$(find "$WORK/iso" -maxdepth 3 -type f -name 'puppy_*.sfs' | head -n 1)"
if [[ -z "$SFS_SOURCE" ]]; then
  SFS_SOURCE="$(find "$WORK/iso" -maxdepth 3 -type f \( -name '*.sfs' -o -name '*.squashfs' \) | sort | head -n 1)"
fi
if [[ -z "$SFS_SOURCE" ]]; then
  echo "No SquashFS root file found inside ISO." >&2
  exit 4
fi
SFS_NAME="$(basename "$SFS_SOURCE")"

echo "[3/7] Extract root filesystem: $SFS_NAME"
unsquashfs -f -d "$WORK/rootfs" "$SFS_SOURCE"

echo "[4/7] Stage Project Infi / ARIS payload"
rsync -aH "$PAYLOAD/" "$WORK/rootfs/"
chmod +x "$WORK/rootfs/opt/cogos/bin/"*

echo "[5/7] Install CoGOS PID 1 gatekeeper and startup layer"
chmod +x "$WORK/rootfs/etc/init.d/90cogos" "$WORK/rootfs/usr/local/bin/"cogos-*
chmod +x "$WORK/rootfs/opt/cogos/modules/local/"*/*.py

NATIVE_INIT_REAL="$(readlink -f "$WORK/rootfs/usr/sbin/init" 2>/dev/null || true)"
if [[ -z "$NATIVE_INIT_REAL" || ! -e "$NATIVE_INIT_REAL" ]]; then
  NATIVE_INIT_REAL="$(readlink -f "$WORK/rootfs/sbin/init" 2>/dev/null || true)"
fi
if [[ -z "$NATIVE_INIT_REAL" || ! -e "$NATIVE_INIT_REAL" ]]; then
  echo "Native init not found at /usr/sbin/init or /sbin/init." >&2
  exit 5
fi
if [[ "$NATIVE_INIT_REAL" == "$WORK/rootfs/opt/cogos/bin/cognitive_init" ]]; then
  echo "Native init already points to CoGOS before preservation." >&2
  exit 5
fi
if [[ ! -e "$WORK/rootfs/usr/sbin/init.original" ]]; then
  cp -a "$NATIVE_INIT_REAL" "$WORK/rootfs/usr/sbin/init.original"
fi
chmod +x "$WORK/rootfs/usr/sbin/init.original"
rm -f "$WORK/rootfs/usr/sbin/init"
ln -s /opt/cogos/bin/cognitive_init "$WORK/rootfs/usr/sbin/init"
if [[ -e "$WORK/rootfs/sbin" && ! -L "$WORK/rootfs/sbin" ]]; then
  rm -f "$WORK/rootfs/sbin/init"
  ln -s /opt/cogos/bin/cognitive_init "$WORK/rootfs/sbin/init"
fi
[[ "$(readlink "$WORK/rootfs/usr/sbin/init")" == "/opt/cogos/bin/cognitive_init" ]] || {
  echo "/usr/sbin/init does not resolve to CoGOS cognitive_init." >&2
  exit 5
}
[[ "$(readlink "$WORK/rootfs/sbin/init")" == "/opt/cogos/bin/cognitive_init" ]] || {
  echo "/sbin/init does not resolve to CoGOS cognitive_init." >&2
  exit 5
}
echo "Preserved native init: /usr/sbin/init.original from ${NATIVE_INIT_REAL#$WORK/rootfs}"

echo "[6/7] Rebuild SquashFS"
mksquashfs "$WORK/rootfs" "$SFS_SOURCE" -comp xz -b 1M -noappend -all-root

echo "[7/7] Rebuild ISO"
if [[ -f "$WORK/iso/isolinux.bin" ]]; then
  EFI_ARGS=()
  if [[ -f "$WORK/iso/boot/efi.img" ]]; then
    EFI_ARGS=(-eltorito-alt-boot -e boot/efi.img -no-emul-boot)
  fi

  xorriso -as mkisofs -D -r -J -l \
    -V "ISOIMAGE" \
    -o "$OUT" \
    -b isolinux.bin \
    -c boot/boot.catalog \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    "${EFI_ARGS[@]}" \
    -isohybrid-gpt-basdat \
    "$WORK/iso"
else
  xorriso -as mkisofs -D -r -J -l -V "ISOIMAGE" -o "$OUT" "$WORK/iso"
fi

echo "Built: $OUT"
