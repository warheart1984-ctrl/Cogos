# CoGOS v12 UL/VOSS Runtime

v12 adds the Universal Language and VOSS execution core as governed local
runtime surfaces. The v11 PID 1 gatekeeper remains the boot authority.

Known-good sequence:

```sh
cogos-ul trace /opt/cogos/examples/ul/hello.ul
cogos-ul substrate /opt/cogos/examples/ul/safe_substrate.ulsub
cogos-voss run-golden
cogos-voss verify-golden
cogos-voss validate
cogos-voss binding-demo
cogos-voss proof
cogos-proof
```

Evidence paths:

```text
/opt/cogos/memory/ul/runs.jsonl
/opt/cogos/memory/ul/substrate_audit.jsonl
/opt/cogos/memory/voss/rep_traces.jsonl
/opt/cogos/memory/voss/verifications.jsonl
/opt/cogos/memory/voss/bindings.jsonl
/opt/cogos/memory/voss/proof.jsonl
```

Substrate adversarial checks:

```sh
cogos-ul substrate /opt/cogos/examples/ul/dangerous_substrate.ulsub
cogos-ul substrate /opt/cogos/examples/ul/oversized_substrate.ulsub
```

Both should fail closed and write audit evidence.
