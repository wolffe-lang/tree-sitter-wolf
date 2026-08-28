# le02 spec findings — where the grammar spec is silent

The tree-sitter grammar is an independent reading of wolf-lang's
`spec/01-grammar.md` (the wolf-interp doctrine). Per the sprint contract,
spec silence is recorded here rather than settled by reading the
compiler's parser. Each entry is drafted as an upstream issue for
wolf-lang; filing is the integrator's act, one `gh issue create` each.

## 1. The unit type `()` is underivable from `[gram.type]`

`corpus/typecheck/main_unit_row.lu` spells the fourth `main` signature as
`fn main() -> !()`. The `[gram.type]` production for tuples is
`'(' type (',' type)* ','? ')'` — at least one type; `()` cannot be
derived, and no other alternative produces a unit type. The corpus and
the spec disagree, and the spec is the one that cannot say `()`.

tree-sitter-wolf admits `(` `)` as a `unit_type` node permissively.

Suggested fix: an explicit alternative (`'(' ')'` or a named `unit`
production) under `[gram.type]`, since `[gram.version.1]` permits
additive change.

## 2. `STR_TEXT` is undefined — a lone `}` in string content

`[gram.lex.str]` derives `STR_PART ::= STR_TEXT | '{{' | '}}' | INTERP`
but never defines `STR_TEXT`'s character set. In particular: is a lone
`}` (not part of `}}`) legal string text, or an error as in Python
f-strings? The `}}` escape existing at all implies lone `}` is special,
but nothing says so.

tree-sitter-wolf admits a lone `}` as content permissively.

## 3. The `[gram.amb.fmtcolon]` annex example uses a form the grammar cannot parse

The annex illustrates the top-level-colon rule with `"{ {a: 1}.a }"`.
The inner `{a: 1}` is a path-less struct literal; `[gram.expr.primary]`
requires `struct_lit ::= path '{' …`, and no production derives an
anonymous `{field: value}` form. The paired corpus file
(`corpus/grammar/interp_nested.lu`) does not actually contain the
example, so nothing catches the drift. Either the example needs a path
(`"{ (Point {a: 1}).a }"`) or the language has an anonymous record form
the grammar does not admit.

## 4. Struct literals cannot name type arguments

`struct_lit ::= path '{' …` — the head is a bare path, so a generic
struct literal (`Pair[int, str] { a: 1, b: "x" }`) is unwritable; the
value must come from inference or a helper. Possibly intended
(types-as-values makes `Pair[int, str]` an expression, and
`[gram.amb.structlit]` already restricts literal positions), but the
spec does not say which reading is meant. tree-sitter-wolf's
`struct_expression` head is a `type_path` (type arguments admitted).
