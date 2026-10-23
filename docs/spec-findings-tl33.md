# tl33 — 0.2.35 prelude functions

## Prediction (before the query changes)

Wolf-lang `v0.2.35` adds thirteen released prelude functions. The highlight
query deliberately carries no prelude-function list: direct calls, including
`fs_access` and `os_name`, remain `@function`. The corpus case proves those
calls parse. `env_arg0` and `env_args_bytes` are unreleased (wolf-lang#904) and
remain absent.

## Findings

The hasu container test attempt could not start `tree-sitter test`: its
installed `tree-sitter-cli` requires `GLIBC_2.39`. CI is the test host.
