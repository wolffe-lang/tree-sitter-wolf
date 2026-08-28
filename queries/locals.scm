; tree-sitter-wolf locals — scopes, definitions, references.
; Earns its place: parameter/local coloring stays stable through
; interpolations because `{expr}` holds real identifier nodes.

; -------------------------------------------------------------- scopes

(source_file) @local.scope
(block) @local.scope
(function_item) @local.scope
(closure_expression) @local.scope
(for_expression) @local.scope
(match_arm) @local.scope
(region_expression) @local.scope
(scope_expression) @local.scope
(else_handler) @local.scope

; --------------------------------------------------------- definitions

(function_item name: (identifier) @local.definition.function)
(parameter name: (identifier) @local.definition.parameter)
(closure_parameter name: (identifier) @local.definition.parameter)
(let_declaration pattern: (identifier) @local.definition.var)
(var_declaration pattern: (identifier) @local.definition.var)
(let_declaration pattern: (tuple_pattern (identifier) @local.definition.var))
(var_declaration pattern: (tuple_pattern (identifier) @local.definition.var))
(const_declaration name: (identifier) @local.definition.constant)
(for_expression pattern: (identifier) @local.definition.var)
(for_expression pattern: (tuple_pattern (identifier) @local.definition.var))
(at_pattern binding: (identifier) @local.definition.var)
(else_handler binding: (identifier) @local.definition.var)
(region_expression name: (identifier) @local.definition.var)
(scope_expression name: (identifier) @local.definition.var)

; ---------------------------------------------------------- references

(identifier) @local.reference
