// tree-sitter-wolf — grammar for the wolf language (`.lu`, lupus).
//
// This is an independent reading of wolf-lang's spec/01-grammar.md
// (grammar/1, the [gram.*] anchors). The spec is the authority; the
// compiler's parser was deliberately not consulted (wolf-interp doctrine).
//
// Design notes, tied to spec anchors:
//
// [gram.lex.newline] — Go-adapted, last-token-only terminator insertion.
//   Modelled with an explicit newline token that is only *valid* where a
//   statement can end, while /\s/ stays in extras. Where the parser is
//   mid-rule (after a binary operator, `.`, `,`, `=`, an open delimiter)
//   no terminator token is valid, so the newline is consumed as trivia —
//   which reproduces the spec's insertion rule: trailing-style
//   continuations parse, leading-operator continuations do not, and the
//   innermost `(`/`[`/interpolation suppresses termination.
//
// [gram.lex.str] — every plain string literal is an f-string. The string
//   rules re-enter full expression mode inside `{…}` (the lexer mode
//   stack falls out of tree-sitter's context-sensitive lexing), so
//   interpolations are real expression nodes and nest arbitrarily.
//   `{{`/`}}` are escape tokens; the first top-level `:` after the
//   interpolated expression begins the format spec ([gram.amb.fmtcolon]),
//   and format specs may themselves contain interpolations (`{n:>{w}}`).
//
// [gram.lex.str.multi] / [gram.lex.str.raw] — triple-quoted content and
//   raw-string fences need unbounded lookahead ("" is content, """ ends;
//   r##"…"## fences balance), so both live in the external scanner
//   (src/scanner.c) and terminate exactly.
//
// [gram.amb.structlit] — no-struct-literal positions (if/while condition,
//   match/for scrutinee, `in` headers) are resolved by GLR: the
//   struct-literal branch dies unless a body block still follows, and
//   `prec.dynamic` prefers the struct literal when both survive (the
//   same-line `Point { x }` case).
//
// [gram.amb.brackets] — `e[…]` is one postfix shape; indexing vs generic
//   application is not distinguished (that is sema's job, D29). The
//   index argument list also admits the type-only forms no expression
//   can spell (`List[handle Node]`, `channel[region]`, `fn(int) -> int`).
//
// Deliberate supersets (a highlighting grammar may be permissive, never
// narrower): comparison operators chain here (spec: parse error E0003);
// `;;` empty statements parse (E0002); comma rules in variant/arm lists
// are relaxed; `(mut x)` receivers parse detached from a `.` (E0210).

const PREC = {
  ELSE: 1,      // `expr else fallback` defaulting (tier 15, loosest)
  RANGE: 2,     // `..` `..=`, `^n` from-end endpoints (tier 14)
  OR: 3,        // `||`
  AND: 4,       // `&&`
  COMPARE: 5,   // `==` `!=` `<` `>` `<=` `>=` `<=>`
  BITOR: 6,     // `|`
  BITXOR: 7,    // `^`
  BITAND: 8,    // `&`
  SHIFT: 9,     // `<<` `>>`
  ADD: 10,
  MUL: 11,
  CAST: 12,     // `as`
  UNARY: 13,    // `!` `-` `&` `&mut` `*` `move` `copy` `shared` `freeze`
  POSTFIX: 15,  // call, index/generic-apply, member, postfix `?`
};

function commaSep1(rule) {
  return seq(rule, repeat(seq(',', rule)), optional(','));
}

function commaSep(rule) {
  return optional(commaSep1(rule));
}

module.exports = grammar({
  name: 'wolf',

  word: $ => $.identifier,

  extras: $ => [/\s/, $.line_comment, $.doc_comment],

  externals: $ => [
    $._multiline_string_content,
    $._raw_string_start,
    $._raw_string_content,
    $._raw_string_end,
    $._error_sentinel,
  ],

  conflicts: $ => [
    // `fn (` opens both a closure (expression) and a fn type where both
    // are admitted (index/type argument lists) — GLR forks, the branch
    // that cannot complete dies.
    [$.path, $.closure_parameter],
    [$.function_type, $.closure_parameters],
    // `ident` alone is a path (type/pattern/struct-literal name — the
    // [gram.amb.structlit] fork rides this) or a plain expression.
    [$.path, $._expression],
    // `()` in an argument-list position: unit expression vs unit type.
    [$.unit_type, $.unit_expression],
  ],

  rules: {
    // ================================================== unit [gram.item.unit]

    // The shebang rides the statement repeat: the spec confines it to
    // byte offset 0 ([gram.lex.shebang]), a constraint LR cannot see —
    // a mid-file `#!` line parses here (permissive; stray-byte tier).
    source_file: $ => repeat(
      choice($._terminator, $.shebang, $._statement),
    ),

    // [gram.lex.shebang] — trivia line; only meaningful at offset 0.
    shebang: _ => token(/#![^\r\n]*/),

    // ============================================ trivia [gram.lex.comment]

    line_comment: _ => token(prec(1, /\/\/[^\r\n]*/)),
    // `//!` inner doc (file/module header), `///` outer doc.
    doc_comment: _ => token(prec(2, /\/\/[\/!][^\r\n]*/)),

    // ======================================= terminators [gram.lex.newline]

    _terminator: $ => choice(';', $._newline),
    _newline: _ => token(prec(1, /\r?\n/)),

    // ============================================ statements [gram.expr.block]

    _statement: $ => choice(
      $.function_item,
      $.struct_item,
      $.enum_item,
      $.type_item,
      $.trait_item,
      $.impl_item,
      $.use_declaration,
      $.import_c_declaration,
      $.let_declaration,
      $.var_declaration,
      $.const_declaration,
      $.assignment_statement,
      $.defer_statement,
      $.assume_statement,
      $.expression_statement,
    ),

    expression_statement: $ => seq(repeat($.attribute), $._expression),

    // Assignment is a statement, not an expression [gram.expr.assign].
    // `place` is any expression; place-ness is sema's check, not grammar's.
    assignment_statement: $ => seq(
      repeat($.attribute),
      field('left', $._expression),
      field('operator', choice(
        '=', '+=', '-=', '*=', '/=', '%=',
        '&=', '|=', '^=', '<<=', '>>=',
      )),
      field('right', $._expression),
    ),

    defer_statement: $ => seq(
      repeat($.attribute),
      choice('defer', 'errdefer'),
      $._expression,
    ),

    // Unsafe-tier statement; legal anywhere in the grammar for recovery
    // quality (D22) — sema confines it to `unsafe`.
    assume_statement: $ => seq(
      'assume',
      'noalias',
      $._expression,
      repeat1(seq(',', $._expression)),
    ),

    // ================================================== items [gram.item]

    visibility_modifier: _ => seq('pub', optional(seq('(', 'pkg', ')'))),

    // -------------------------------------------- imports [gram.item.use]

    use_declaration: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'use',
      $.use_path,
      optional(seq('as', field('alias', $.identifier))),
    ),

    use_path: $ => seq(
      $.identifier,
      repeat(seq('.', $.identifier)),
      optional(seq('.', $.use_group)),
    ),

    use_group: $ => seq('{', commaSep1($.identifier), '}'),

    import_c_declaration: $ => seq(
      repeat($.attribute),
      'import',
      'c',
      field('header', $.string_literal),
    ),

    // ------------------------------------------ functions [gram.item.fn]

    function_item: $ => prec.right(seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      repeat($.function_qualifier),
      'fn',
      field('name', $.identifier),
      optional(field('type_parameters', $.generic_parameters)),
      field('parameters', $.parameters),
      optional(seq('->', field('return_type', $._type))),
      optional(field('body', $.block)),   // bodyless: extern / trait member
    )),

    function_qualifier: $ => choice(
      'comptime',
      seq('extern', $.string_literal),
      'export',
    ),

    generic_parameters: $ => seq('[', commaSep1($.generic_parameter), ']'),

    generic_parameter: $ => seq(
      field('name', $.identifier),
      optional(seq(':', field('bound', $._generic_bound))),
    ),

    _generic_bound: $ => choice(
      alias('type', $.type_keyword),   // `T: type` — comptime type param
      $.trait_bound,
    ),

    trait_bound: $ => seq($.path, repeat(seq('+', $.path))),

    parameters: $ => seq('(', commaSep($._parameter), ')'),

    _parameter: $ => choice($.parameter, $.self_parameter),

    parameter: $ => seq(
      optional($.parameter_mode),
      field('name', $.identifier),
      ':',
      field('type', $._type),
    ),

    // `self` is contextual: a keyword only in receiver position.
    self_parameter: $ => seq(
      optional($.parameter_mode),
      alias('self', $.self),
      optional($.view_set),
    ),

    // `mut self.{x, y}` — field-granular exclusivity.
    view_set: $ => seq('.', '{', commaSep1($.identifier), '}'),

    parameter_mode: _ => choice('mut', 'take'),

    // ------------------------------- bindings & constants [gram.item.let]

    let_declaration: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'let',
      field('pattern', $._pattern),
      optional(seq(':', field('type', $._type))),
      '=',
      field('value', $._expression),
    ),

    var_declaration: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'var',
      field('pattern', $._pattern),
      optional(seq(':', field('type', $._type))),
      '=',
      field('value', $._expression),
    ),

    const_declaration: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'const',
      field('name', $.identifier),
      optional(seq(':', field('type', $._type))),
      '=',
      field('value', $._expression),
    ),

    // ---------------------------------------------- types [gram.item.type]

    type_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'type',
      field('name', $.identifier),
      optional(field('type_parameters', $.generic_parameters)),
      '=',
      field('body', choice(
        $.struct_definition,
        $.enum_definition,
        $._type,               // includes `distinct T` via prefixed_type
      )),
    ),

    struct_definition: $ => seq('struct', $.field_declaration_list),
    enum_definition: $ => seq('enum', $.enum_variant_list),

    // Item-level sugar: `struct Name { … }`, `enum Name { … }`.
    struct_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'struct',
      field('name', $.identifier),
      optional(field('type_parameters', $.generic_parameters)),
      field('body', $.field_declaration_list),
    ),

    enum_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'enum',
      field('name', $.identifier),
      optional(field('type_parameters', $.generic_parameters)),
      field('body', $.enum_variant_list),
    ),

    // Fields are newline-separated declarations, per-field `','?`.
    field_declaration_list: $ => seq('{', repeat($.field_declaration), '}'),

    field_declaration: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      field('name', $.identifier),
      ':',
      field('type', $._type),
      optional(','),
    ),

    // Variants are comma-punctuated alternatives (commas relaxed here).
    enum_variant_list: $ => seq(
      '{',
      repeat(seq($.enum_variant, optional(','))),
      '}',
    ),

    enum_variant: $ => seq(
      field('name', $.identifier),
      optional(seq('(', commaSep1($._type), ')')),
    ),

    // -------------------------------------- traits & impls [gram.item.trait]

    trait_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'trait',
      field('name', $.identifier),
      optional(field('type_parameters', $.generic_parameters)),
      field('body', $.declaration_list),
    ),

    impl_item: $ => seq(
      repeat($.attribute),
      optional($.visibility_modifier),
      'impl',
      optional(field('type_parameters', $.generic_parameters)),
      field('type', $._type),
      optional(seq('for', field('for_type', $._type))),
      field('body', $.declaration_list),
    ),

    declaration_list: $ => seq(
      '{',
      repeat(choice(
        $.function_item,
        $.type_item,
        $.const_declaration,
        $._terminator,
      )),
      '}',
    ),

    // --------------------------------------- attributes [gram.item.attr]

    attribute: $ => seq('#[', commaSep1($.attr_item), ']'),

    attr_item: $ => seq(
      $.path,
      optional(choice(
        seq('(', commaSep($._attr_arg), ')'),
        seq('=', $._literal),
      )),
    ),

    _attr_arg: $ => choice($.attr_item, $._literal),

    // ================================================== types [gram.type]

    _type: $ => choice(
      $.type_path,
      $.error_union_type,
      $.rowed_type,
      $.prefixed_type,
      $.pointer_type,
      $.dyn_type,
      $.tuple_type,
      $.unit_type,
      $.function_type,
      alias('type', $.type_keyword),      // the type of types (comptime)
      alias('region', $.region_type),     // first-class regions (X4)
    ),

    type_path: $ => prec.right(seq($.path, optional(field('type_arguments', $.type_arguments)))),

    path: $ => prec.right(seq($.identifier, repeat(seq('.', $.identifier)))),

    // `!T` — error union with inferred private row (D30).
    error_union_type: $ => prec.right(1, seq('!', $._type)),

    // `T ! {row}` — postfix row, first-class in every type position;
    // nested rows flatten ([gram.type.row.flatten], D51).
    rowed_type: $ => prec.left(2, seq($._type, '!', $.error_row)),

    error_row: $ => seq(
      '{',
      optional(commaSep1(choice($.row_entry, alias('..', $.open_row)))),
      '}',
    ),

    row_entry: $ => seq(
      $.path,
      optional(seq('(', commaSep1($._type), ')')),
    ),

    // `shared Config`, `handle Node`, `weak Parent`, `distinct Song`.
    prefixed_type: $ => prec.right(seq(
      field('modifier', choice('shared', 'handle', 'weak', 'distinct')),
      $._type,
    )),

    pointer_type: $ => prec.right(seq('*', $._type)),   // raw pointer, unsafe tier

    dyn_type: $ => seq('dyn', $.path),

    tuple_type: $ => seq('(', $._type, repeat(seq(',', $._type)), optional(','), ')'),

    // `()` — the unit type. The corpus spells `fn main() -> !()`, but the
    // spec's [gram.type] production cannot derive an empty tuple type;
    // admitted here permissively (spec silence filed upstream).
    unit_type: _ => seq('(', ')'),

    function_type: $ => prec.right(seq(
      'fn',
      '(',
      commaSep($._type),
      ')',
      optional(seq('->', $._type)),
    )),

    type_arguments: $ => seq('[', commaSep1($._type_arg), ']'),

    // Const generics: `type | expr`, disambiguated in sema [gram.type].
    _type_arg: $ => choice($._type, $._expression),

    // ================================================ patterns [gram.pat]

    _pattern: $ => choice($._closed_pattern, $.or_pattern),

    or_pattern: $ => prec.left(seq($._pattern, '|', $._pattern)),

    _closed_pattern: $ => choice(
      alias('_', $.wildcard_pattern),
      $._literal_pattern,
      $.identifier,
      $.tuple_pattern,
      $.constructor_pattern,
      $.at_pattern,
    ),

    _literal_pattern: $ => choice(
      $._literal,
      $.negative_literal,
    ),

    negative_literal: $ => seq('-', choice($.integer_literal, $.float_literal)),

    tuple_pattern: $ => seq('(', commaSep1($._pattern), ')'),

    constructor_pattern: $ => seq(
      field('type', $.path),
      '(',
      commaSep1($._pattern),
      ')',
    ),

    at_pattern: $ => seq(
      field('binding', $.identifier),
      '@',
      $._closed_pattern,
    ),

    // ========================================== expressions [gram.expr]

    _expression: $ => choice(
      $.identifier,
      $._literal,
      $.unary_expression,
      $.reference_expression,
      $.binary_expression,
      $.cast_expression,
      $.range_expression,
      $.from_end_expression,
      $.else_expression,
      $.call_expression,
      $.index_expression,
      $.field_expression,
      $.try_expression,
      $.parenthesized_expression,
      $.tuple_expression,
      $.unit_expression,
      $.moded_receiver,
      $.struct_expression,
      $.block,
      $.if_expression,
      $.match_expression,
      $.for_expression,
      $.while_expression,
      $.loop_expression,
      $.closure_expression,
      $.region_expression,
      $.in_expression,
      $.scope_expression,
      $.select_expression,
      $.when_expression,
      $.unsafe_expression,
      $.spawn_expression,
      $.asm_expression,
      $.borrow_expression,
      $.return_expression,
      $.break_expression,
      $.continue_expression,
    ),

    // ------------------------------------------ blocks [gram.expr.block]

    block: $ => seq(
      '{',
      repeat(choice($._terminator, $._statement)),
      '}',
    ),

    // --------------------------------- operators & climb [gram.expr.prec]

    unary_expression: $ => prec(PREC.UNARY, seq(
      field('operator', choice('!', '-', '*', 'move', 'copy', 'shared', 'freeze')),
      field('operand', $._expression),
    )),

    // Tier-0 local borrows: `&x`, `&mut x` (second-class at boundaries).
    reference_expression: $ => prec(PREC.UNARY, seq(
      '&',
      optional('mut'),
      field('operand', $._expression),
    )),

    binary_expression: $ => {
      const table = [
        [PREC.MUL, choice('*', '/', '%')],
        [PREC.ADD, choice('+', '-')],
        [PREC.SHIFT, choice('<<', '>>')],
        [PREC.BITAND, '&'],
        [PREC.BITXOR, '^'],
        [PREC.BITOR, '|'],
        [PREC.COMPARE, choice('==', '!=', '<', '>', '<=', '>=', '<=>')],
        [PREC.AND, '&&'],
        [PREC.OR, '||'],
      ];
      return choice(...table.map(([p, op]) => prec.left(p, seq(
        field('left', $._expression),
        field('operator', op),
        field('right', $._expression),
      ))));
    },

    cast_expression: $ => prec.left(PREC.CAST, seq(
      field('value', $._expression),
      'as',
      field('type', $._type),
    )),

    range_expression: $ => choice(
      prec.left(PREC.RANGE, seq(
        field('start', $._expression),
        field('operator', choice('..', '..=')),
        optional(field('end', $._expression)),
      )),
      prec.left(PREC.RANGE, seq(
        field('operator', choice('..', '..=')),
        field('end', $._expression),
      )),
    ),

    // `^n` — from-end endpoint (D25): `s[^1]`, `s[^13..]`, `s[..^1]`.
    // Binds tighter than the range operator: `^13..` is `(^13)..`.
    from_end_expression: $ => prec.left(PREC.RANGE + 1, seq('^', $._expression)),

    // `expr else fallback` — defaulting operator, loosest tier;
    // `expr else |pat| handler` binds the error ([gram.expr.primary]).
    else_expression: $ => prec.right(PREC.ELSE, seq(
      field('value', $._expression),
      'else',
      field('fallback', choice(
        $.else_handler,
        $._expression,
      )),
    )),

    else_handler: $ => prec.right(seq(
      '|',
      field('binding', $._closed_pattern),
      '|',
      field('body', $._expression),
    )),

    // ------------------------------------- postfix [gram.expr.primary]

    call_expression: $ => prec(PREC.POSTFIX, seq(
      field('function', $._expression),
      field('arguments', $.arguments),
    )),

    // Call-site modes (X1): `f(mut x)`, `f(take conn)`.
    arguments: $ => seq('(', commaSep($.argument), ')'),

    argument: $ => seq(optional($.parameter_mode), $._expression),

    // `e[…]` — one postfix shape for indexing AND generic application
    // [gram.amb.brackets]; admits type-only argument forms.
    index_expression: $ => prec(PREC.POSTFIX, seq(
      field('value', $._expression),
      '[',
      commaSep($._index_arg),
      ']',
    )),

    _index_arg: $ => choice(
      seq(optional($.parameter_mode), $._expression),
      $.prefixed_type,
      $.function_type,
      $.pointer_type,
      $.dyn_type,
      $.error_union_type,
      alias('region', $.region_type),
    ),

    // Member position is keyword-transparent; tuple access is `.0`.
    field_expression: $ => prec(PREC.POSTFIX, seq(
      field('value', $._expression),
      '.',
      field('field', choice($.identifier, $.integer_literal)),
    )),

    try_expression: $ => prec(PREC.POSTFIX, seq(
      field('value', $._expression),
      '?',
    )),

    // ------------------------------------- primaries [gram.expr.primary]

    parenthesized_expression: $ => seq('(', $._expression, ')'),

    tuple_expression: $ => seq(
      '(',
      $._expression,
      ',',
      optional(seq($._expression, repeat(seq(',', $._expression)), optional(','))),
      ')',
    ),

    unit_expression: _ => seq('(', ')'),

    // Receiver modes (X1): `(mut p).norm()`, `(take conn).close()`.
    // The `.`-must-follow rule (E0210) is sema-tier here.
    moded_receiver: $ => seq(
      '(',
      $.parameter_mode,
      $._expression,
      ')',
    ),

    // `Point { x: 0, y }` — struct literal; illegal in condition/scrutinee
    // position, which GLR + dynamic precedence resolves [gram.amb.structlit].
    struct_expression: $ => prec.dynamic(1, seq(
      field('name', $.type_path),
      field('body', $.field_initializer_list),
    )),

    field_initializer_list: $ => seq(
      '{',
      commaSep(choice($.field_initializer, $.shorthand_field_initializer)),
      '}',
    ),

    field_initializer: $ => seq(
      field('name', $.identifier),
      ':',
      field('value', $._expression),
    ),

    shorthand_field_initializer: $ => $.identifier,

    // ------------------------------------ control flow [gram.expr.flow]

    if_expression: $ => prec.right(seq(
      'if',
      field('condition', $._expression),
      field('consequence', $.block),
      optional(seq(
        'else',
        field('alternative', choice($.if_expression, $.block)),
      )),
    )),

    match_expression: $ => seq(
      'match',
      field('value', $._expression),
      field('body', $.match_body),
    ),

    match_body: $ => seq(
      '{',
      repeat(choice($.match_arm, ',', $._terminator)),
      '}',
    ),

    match_arm: $ => prec.right(seq(
      field('pattern', $._pattern),
      optional(seq('if', field('guard', $._expression))),
      '=>',
      field('body', $._expression),
    )),

    for_expression: $ => seq(
      'for',
      field('pattern', $._pattern),
      'in',
      field('value', $._expression),
      field('body', $.block),
    ),

    while_expression: $ => seq(
      'while',
      field('condition', $._expression),
      field('body', $.block),
    ),

    loop_expression: $ => seq('loop', field('body', $.block)),

    return_expression: $ => prec.right(seq('return', optional($._expression))),
    break_expression: $ => prec.right(seq('break', optional($._expression))),
    continue_expression: _ => 'continue',

    // ---------------------------------------- closures [gram.expr.closure]

    // Expression bodies extend maximally rightward [gram.amb.closure].
    closure_expression: $ => prec.right(seq(
      'fn',
      field('parameters', $.closure_parameters),
      field('body', $._expression),
    )),

    closure_parameters: $ => seq('(', commaSep($.closure_parameter), ')'),

    closure_parameter: $ => seq(
      optional($.parameter_mode),
      field('name', $.identifier),
      optional(seq(':', field('type', $._type))),
    ),

    // ------------------------------------------ regions [gram.expr.region]

    region_expression: $ => choice(
      // sugar: `region tmp { … }`, `region r: pool(Node) { … }`
      seq(
        'region',
        optional(field('name', $.identifier)),
        optional(seq(':', field('strategy', $.region_strategy))),
        field('body', $.block),
      ),
      // value: `region()`, `region(rc)`
      seq('region', '(', optional(field('strategy', $.region_strategy)), ')'),
    ),

    // `rc` / `pool` are contextual keywords [gram.inv.ctx].
    region_strategy: $ => choice(
      'rc',
      seq('pool', '(', $._type, ')'),
    ),

    // `in r { … }` — allocations land in r.
    in_expression: $ => seq(
      'in',
      field('region', $._expression),
      field('body', $.block),
    ),

    // ------------------------------------- concurrency [gram.expr.conc]

    scope_expression: $ => seq(
      'scope',
      optional(field('name', $.identifier)),
      field('body', $.block),
    ),

    spawn_expression: $ => seq(
      'spawn',
      'proc',
      field('function', $.path),
      field('arguments', $.arguments),
    ),

    select_expression: $ => seq(
      'select',
      '{',
      repeat(choice($.select_arm, ',', $._terminator)),
      '}',
    ),

    // `from` and `timeout` are contextual [gram.inv.ctx].
    select_arm: $ => prec.right(choice(
      seq(
        field('pattern', $._pattern),
        'from',
        field('channel', $._expression),
        '=>',
        field('body', $._expression),
      ),
      seq(
        'timeout',
        '(',
        field('duration', $._expression),
        ')',
        '=>',
        field('body', $._expression),
      ),
    )),

    when_expression: $ => seq(
      'when',
      '(',
      $._expression,
      repeat1(seq(',', $._expression)),
      optional(','),
      ')',
      field('body', $.block),
    ),

    // ------------------------------------- unsafe tier [gram.expr.unsafe]

    unsafe_expression: $ => choice(
      seq('unsafe', field('body', $.block)),
      seq('unsafe', 'c', optional($.capture_list), field('body', $.c_block)),
    ),

    capture_list: $ => seq('[', commaSep1($.identifier), ']'),

    // Inline-C bodies are opaque token text (brace-balanced scan; c10).
    c_block: $ => seq(
      '{',
      repeat(choice(alias(token(prec(-1, /[^{}]+/)), $.c_code), $.c_block)),
      '}',
    ),

    asm_expression: $ => seq(
      'asm',
      '{',
      $.string_literal,
      repeat(seq(',', $.asm_operand)),
      optional(','),
      '}',
    ),

    asm_operand: $ => seq(
      optional(seq(field('name', $.identifier), '=')),
      field('direction', choice('in', 'out', 'inout', 'lateout')),
      '(',
      field('constraint', $.identifier),
      ')',
      $._expression,
    ),

    borrow_expression: $ => prec.right(seq(
      'borrow',
      field('value', $._expression),
      'from',
      field('source', $._expression),
    )),

    // ================================== literals & strings [gram.lex.str]

    _literal: $ => choice(
      $.integer_literal,
      $.float_literal,
      $.string_literal,
      $.multiline_string_literal,
      $.raw_string_literal,
      $.generalized_string_literal,
      $.boolean_literal,
    ),

    boolean_literal: _ => choice('true', 'false'),

    integer_literal: _ => token(choice(
      /[0-9][0-9_]*/,
      /0x[0-9a-fA-F][0-9a-fA-F_]*/,
      /0o[0-7][0-7_]*/,
      /0b[01][01_]*/,
    )),

    // Digits on BOTH sides of the dot ([gram.lex.number]); `1.e5` is
    // member access, `1e5` is a float.
    float_literal: _ => token(choice(
      /[0-9][0-9_]*\.[0-9][0-9_]*([eE][+-]?[0-9][0-9_]*)?/,
      /[0-9][0-9_]*[eE][+-]?[0-9][0-9_]*/,
    )),

    // Every plain string literal is an f-string (X9/D26): `{expr}` is a
    // real expression node, and nests via the mode stack.
    string_literal: $ => seq(
      '"',
      repeat(choice(
        $._string_content,
        $.escape_sequence,
        $.brace_escape,
        $.interpolation,
      )),
      '"',
    ),

    _string_content: _ => token.immediate(prec(1, /[^"\\{\r\n]+/)),

    // `{{` and `}}` are literal braces [gram.lex.str.escape].
    brace_escape: _ => token.immediate(prec(2, /\{\{|\}\}/)),

    escape_sequence: _ => token.immediate(prec(2,
      /\\(x[0-9a-fA-F]{2}|u\{[0-9a-fA-F]+\}|.)/,
    )),

    // Inside the braces the lexer re-enters normal token mode; the first
    // top-level `:` starts the format spec [gram.amb.fmtcolon].
    interpolation: $ => seq(
      token.immediate('{'),
      $._expression,
      optional($.format_spec),
      '}',
    ),

    // Format specs may interpolate their own parameters: `{n:>{w}}`.
    format_spec: $ => seq(
      ':',
      repeat1(choice(
        token.immediate(prec(1, /[^{}"\\\r\n]+/)),
        $.interpolation,
      )),
    ),

    // `"""` — content lives in the external scanner so the literal ends
    // exactly at the next `"""` ([gram.lex.str.multi]): lone `"` and `""`
    // are content, and interpolation still works inside.
    multiline_string_literal: $ => seq(
      '"""',
      repeat(choice(
        alias($._multiline_string_content, $.string_content),
        $.escape_sequence,
        $.brace_escape,
        $.interpolation,
      )),
      '"""',
    ),

    // `r"…"`, `r#"…"#`, `r##"…"##` — no escapes, no interpolation,
    // `#`-fences balance (external scanner) [gram.lex.str.raw].
    raw_string_literal: $ => seq(
      $._raw_string_start,
      optional(alias($._raw_string_content, $.string_content)),
      $._raw_string_end,
    ),

    // `re"[a-z]+"`, `path"/etc/hosts"` — raw-mode body, desugars to a
    // comptime call [gram.lex.str.gen].
    generalized_string_literal: $ => seq(
      field('prefix', $.identifier),
      token.immediate('"'),
      optional(alias(token.immediate(/[^"\r\n]+/), $.string_content)),
      token.immediate('"'),
    ),

    // ================================================== identifiers

    identifier: _ => /[_\p{XID_Start}][\p{XID_Continue}]*/,
  },
});
