# CoGOS v11 Fast Operator Boot And PID 1 Gate

v11 keeps the fast operator behavior from v10, but moves CoGOS earlier in the
boot chain. The kernel starts `cognitive_init` as PID 1, CoGOS verifies law and
runtime integrity, starts the governed daemon, then hands off to native init.

## Boot Profile

Path inside the ISO:

```text
/opt/cogos/config/boot_profile.json
```

Default:

```json
{
  "profile": "operator_shell",
  "dashboard_autostart": false,
  "daemon_autostart": true,
  "boot_verify_autostart": true
}
```

## First Commands

```sh
cogos-operator
cogos-perf
cogos-proof
```

Use the dashboard only when you want the visual runtime view:

```sh
cogos-dashboard-start
```

Stop it when the VM feels heavy:

```sh
cogos-dashboard-stop
```

## Desktop

Puppy/Trixie desktop is still available. CoGOS v11 gates boot first, then
treats the operator shell as the preferred first surface.

```sh
cogos-desktop-hint
```

## Hyper-V Defaults

The v11 helper scripts use:

- 4 virtual CPUs
- fixed 6GB startup memory
- dynamic memory disabled

Tune an existing VM from an elevated Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File "E:\project-infi\AI OS Trixie Build\scripts\tune_hyperv_vm.ps1"
```

## Governance

Governance stack remains available after PID 1 handoff:

- Law Engine
- Sandboxed module execution
- Trait Identity Runtime
- Pattern Ledger
- Immune recommendations
- `cogos-proof`

## PID 1 Proof

```sh
cogos-pid1-proof
cogos-proof
```

`cogos-proof` includes `pid1_gate_ok`.
