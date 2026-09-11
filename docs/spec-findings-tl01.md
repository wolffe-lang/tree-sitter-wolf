# tl01 — the v0.2.11 re-vendor

tl01 re-read the spec diff `v0.2.6..v0.2.11` (`spec/grammar.ebnf`,
`spec/01-grammar.md`, `spec/anchors.json`) against this grammar. Five
releases, 1183 added lines across ten spec files — and four syntax
deltas, three of which the ebnf carries and one of which it does not.

## 0. The measurement

`git diff v0.2.6 v0.2.11 -- spec/grammar.ebnf` is six lines, three
productions:

```
-trait_item ::= 'trait' IDENT generics? '{' trait_member* '}'
+trait_item ::= 'trait' IDENT generics? ('{' trait_member* '}' | '=' bound TERM?)

-if_expr    ::= 'if' expr block ('else' (if_expr | block))?
+if_expr    ::= 'if' expr 'then'? block ('else' (if_expr | block))?
+             | 'if' expr 'then' expr  ('else' (if_expr | expr))?

 closed_pattern ::= '_' | literal | IDENT
           | IDENT '@' closed_pattern
+          | literal ('..' | '..=') literal    /* [gram.pat.range] */
```

All three landed here. The fourth delta is in `spec/01-grammar.md` §1.6
and nowhere in the ebnf, and is the finding below.

`[gram.inv.kw]` is unchanged and still checksums at 50: no release in
this window added a reserved word, so no `@keyword` list in
`queries/highlights.scm` grew by a reserved name.

## 1. The ebnf is not the whole syntax: wolf-lang#276 is a lexer rule

`[gram.lex.newline]` gained an exception at v0.2.9 (ruled 2026-09-09,
wolf-lang#276, retiring E0005):

> No terminator is inserted at a newline when the next token is `else`
> (one token of lookahead; trivia between the newline and the `else` —
> blank lines, comments — does not count).

Terminator insertion is a lexer rule and `spec/grammar.ebnf` writes it
as the opaque `TERM`, so the extracted grammar shows nothing at all.
A reader re-vendoring from the ebnf alone would have shipped a grammar
that ERRORs on `corpus/grammar/else_chain.lu` and
`corpus/grammar/else_default_newline.lu`, both of which are `check:
pass`/`run` files and therefore gated.

Both files did ERROR here before this lane. **The lesson is the
procedure, not the rule**: `spec/grammar.ebnf` is the productions, and
`spec/01-grammar.md` §1.6 is the rest of the syntax. A re-vendor reads
both.

It is implemented in `src/scanner.c` (`NEWLINE_BEFORE_ELSE`) rather
than in `grammar.js`. The grammar-level spelling — letting the newline
token stay valid in front of `else` and leaving GLR to kill the reading
that ended the statement — was written and measured first, and it is
wrong twice: tree-sitter resolves the shift/reduce statically in favour
of the shift, so *every* newline after an expression became an ERROR;
and had it been forced to fork, it would have forked on every line of
every file. The scanner reads the same one token of lookahead the spec
names, past the same trivia the spec excludes, and the parse stays
deterministic.

## 2. `then` is contextual, and the contextual-keyword inventory does not say so

s151 (wolf-lang#307) states it twice in §5's `[gram.expr.if]` prose —
"`then` is **contextual, not reserved** — `[gram.inv.kw]`'s closed set
is unchanged at 50" — and the ebnf's `reserved_kw` confirms it by
omission.

`[gram.inv.ctx]` §6.2, the inventory whose whole job is to name the
contextual keywords, is **byte-identical at v0.2.6 and v0.2.11** and
does not list `then`. Every other contextual word is there (`c`, `rc`,
`pool`, `from`, `timeout`, `noalias`, `pkg`, `reg`, `self`, the asm
directions). The rule is stated normatively in §5 and the index of it
was not updated.

Filed against wolf-lang. Nothing here depends on the fix: this grammar
reads §5, and `then` is a contextual keyword in it.

Contextuality costs this grammar nothing to enforce, which is worth
writing down because it looks like it should. `word: $ => $.identifier`
means tree-sitter extracts keywords from the word token, and an
extracted keyword is only produced in states that admit it. The one
state that admits `then` is the one after a complete `if` condition.
So `let then = true` binds an identifier, `if then { … }` reads the
condition as an identifier, `if then then 1 else 0` reads the
identifier first and the keyword second, and `less.then(greater)` is a
member name — because `field_expression` takes `identifier` and the
`then` token is not valid there. Measured on the twelve `if_then_*.lu`
witnesses: 16 `then` tokens paint `@keyword.control.conditional` and 6
do not (three `identifier` bindings, two `.then(` member calls, one
`fn then` declaration).

The one thing the grammar does decide is the overlap between the two
`if_expr` alternatives: a block is also an expression, so
`if c then { 29 }` matches both. The braced alternative outranks the
bare one (`PREC.IF_BRACED` over `PREC.IF_BARE`), which is the ebnf's
own order, and it keeps `consequence` a `block` node wherever braces
are written. The bare alternative in turn outranks `PREC.ELSE`, so the
`if`'s own `else` binds before the defaulting `else` of
`else_expression` ([gram.amb.else]) — which is why the parentheses in
`corpus/grammar/if_then_paren_default.lu` are load-bearing and the
formatter keeps them.

## 3. s154's `fn_body?` asked for nothing

The contract named a third delta: a bodiless `fn` member standing
directly before its trait's closing brace. `fn_item ::= … (block |
TERM)` is unchanged across this window, and `grammar.js` has carried
`optional(field('body', $.block))` since the extern-function work.
`corpus/traits/op_eq_inverting.lu` — whose `trait Eq` holds exactly one
bodiless member and then `}` — parsed at zero ERROR nodes *before* this
lane touched anything.

Nothing was changed for it. It is now pinned by a test of its own
(`items.txt`, "s154: a bodiless member directly before the trait's
closing brace") so the next reader measures it instead of re-deriving
it. The pre-existing test covered a bodiless member followed by a
*provided* one, which is a different shape and would not have caught a
regression at the brace.

## 4. The floor, re-measured

The ratchet tracks wolf-lang's default branch. Re-measured 2026-09-11
at trunk `be348b9`: 575 `.lu` files, 29 parse-tier counter-examples
excluded by directive, **546 gated**, zero ERROR nodes. `v0.2.11`
itself gates 541 of 570 — trunk carries five more files than the tag.
The floor moves 483 → 546.

The four new exclusions are all E0201 refusals the spec names: s151's
three `if`/`then` spellings it declines (`if_then_missing` — neither
`{` nor `then`; `if_then_mixed` — a bare branch and a braced `else`;
`if_then_let_body` — a `let` in a bare branch) and s147's open range
arm (`match_range_open` — `..hi` and `lo..` are slice spellings, not
patterns). A highlighting grammar may be permissive, so this grammar
accepts `if_then_mixed`; it is excluded by the directive, not by what
it parses to.
