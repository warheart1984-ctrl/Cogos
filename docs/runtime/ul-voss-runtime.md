# UL/VOSS Runtime Architecture

UL and VOSS are staged as local CoGOS runtimes, not network packages and not
admitted modules. The daemon provides the governed adapter layer.

Execution path:

```text
operator command -> law evaluation -> UL/VOSS adapter -> runtime execution -> JSONL evidence -> proof/dashboard
```

UL language runs through `ul_lang.py`. UL substrate runs through
`ul_substrate.py` and its AST-native `ForgeGate`.

VOSS runs through `voss_binary.py` for golden-path REP traces and verifier
results, and through `voss_binding.py` for binding/cycle-boundary proof.

All public commands emit deterministic JSON where practical.
