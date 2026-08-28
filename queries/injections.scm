; tree-sitter-wolf injections.

; comment grammar inside comments (TODO/FIXME etc.)
((line_comment) @injection.content
  (#set! injection.language "comment"))

((doc_comment) @injection.content
  (#set! injection.language "comment"))

; `unsafe c { … }` bodies are C, verbatim (brace-balanced opaque scan)
((c_block (c_code) @injection.content)
  (#set! injection.language "c")
  (#set! injection.combined))

; `re"[a-z]+"` generalized literals carry a regex body
((generalized_string_literal
   prefix: (identifier) @_prefix
   (string_content) @injection.content)
  (#eq? @_prefix "re")
  (#set! injection.language "regex"))
