# tl33 — 0.2.35 prelude functions

## Prediction (before the query changes)

Wolf-lang `v0.2.35` adds thirteen released prelude functions. The highlight
query should tag direct calls to them as `@function.builtin`; calls to arbitrary
identifiers must remain `@function`. The corpus case names `fs_access` and
`os_name`. `env_arg0` and `env_args_bytes` are unreleased (wolf-lang#904) and
remain absent.
