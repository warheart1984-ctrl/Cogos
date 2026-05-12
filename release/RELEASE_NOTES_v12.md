# CoGOS v12 Release Notes

Release: `project-infi-aris-trixie-full-os-v12.iso`

SHA-256:

```text
a95af10ec22f3704a6cb02041388e5040f67159795337e12a107116b8df667fa
```

CoGOS v12 adds UL/VOSS Governed Runtime while preserving the v11 PID 1
gatekeeper boot chain.

## Added

- UL language execution and tracing with `cogos-ul`.
- UL substrate execution through ForgeGate capability checks.
- VOSS golden-path run, verifier, validation suite, binding demo, and proof.
- UL/VOSS evidence under `/opt/cogos/memory/ul` and `/opt/cogos/memory/voss`.
- Dashboard and `cogos-proof` fields for UL/VOSS status.

## Known-Good Sequence

```sh
cogos-pid1-proof
cogos-ul trace /opt/cogos/examples/ul/hello.ul
cogos-ul substrate /opt/cogos/examples/ul/safe_substrate.ulsub
cogos-voss proof
cogos-proof
```

## Unchanged

- Puppy/Trixie remains the substrate.
- v11 PID 1 gatekeeper remains the boot authority.
- Dashboard remains on-demand.
- Module sandboxing, Trait Identity Runtime, Pattern Ledger, and immune runtime
  remain in place.
