// tree-sitter-wolf external scanner.
//
// Owns the two string forms whose lexing needs unbounded lookahead or
// balanced fences — the parts a regex-only lexer gets wrong:
//
//   [gram.lex.str.multi]  `"""` content: a lone `"` or `""` is content,
//                         the literal ends exactly at the next `"""`.
//   [gram.lex.str.raw]    r"…", r#"…"#, r##"…"## — the `#` fences
//                         balance; the opening fence depth is carried in
//                         serialized scanner state.
//
// Multiline content also stops at `\` (escape) and `{` (interpolation —
// f-string mode works inside `"""`), handing those back to the grammar.

#include "tree_sitter/parser.h"
#include <stdlib.h>

enum TokenType {
  MULTILINE_STRING_CONTENT,
  RAW_STRING_START,
  RAW_STRING_CONTENT,
  RAW_STRING_END,
  ERROR_SENTINEL,
};

typedef struct {
  // `#` count of the raw string currently open (0 = r"…" or none open).
  uint8_t raw_fence;
  bool in_raw;
} Scanner;

void *tree_sitter_wolf_external_scanner_create(void) {
  Scanner *s = (Scanner *)calloc(1, sizeof(Scanner));
  return s;
}

void tree_sitter_wolf_external_scanner_destroy(void *payload) {
  free(payload);
}

unsigned tree_sitter_wolf_external_scanner_serialize(void *payload, char *buffer) {
  Scanner *s = (Scanner *)payload;
  buffer[0] = (char)s->raw_fence;
  buffer[1] = (char)s->in_raw;
  return 2;
}

void tree_sitter_wolf_external_scanner_deserialize(void *payload, const char *buffer,
                                                   unsigned length) {
  Scanner *s = (Scanner *)payload;
  s->raw_fence = 0;
  s->in_raw = false;
  if (length >= 2) {
    s->raw_fence = (uint8_t)buffer[0];
    s->in_raw = (bool)buffer[1];
  }
}

static inline void advance(TSLexer *lexer) { lexer->advance(lexer, false); }

// --------------------------------------------------------------- raw strings

static bool scan_raw_string_start(Scanner *s, TSLexer *lexer) {
  if (lexer->lookahead != 'r') return false;
  advance(lexer);
  uint8_t fence = 0;
  while (lexer->lookahead == '#' && fence < 255) {
    fence++;
    advance(lexer);
  }
  if (lexer->lookahead != '"') return false;   // plain identifier `r`, `r#…`
  advance(lexer);
  s->raw_fence = fence;
  s->in_raw = true;
  lexer->result_symbol = RAW_STRING_START;
  return true;
}

static bool scan_raw_string(Scanner *s, TSLexer *lexer, const bool *valid) {
  bool have_content = false;
  for (;;) {
    if (lexer->eof(lexer)) break;
    if (lexer->lookahead == '"') {
      // Candidate close: `"` + fence `#`s. Mark before consuming so a
      // non-closing quote (short fence) stays inside the content token.
      lexer->mark_end(lexer);
      advance(lexer);
      uint8_t seen = 0;
      while (seen < s->raw_fence && lexer->lookahead == '#') {
        seen++;
        advance(lexer);
      }
      if (seen == s->raw_fence) {
        // Real close. Emit pending content first, else emit the end token.
        if (have_content && valid[RAW_STRING_CONTENT]) {
          lexer->result_symbol = RAW_STRING_CONTENT;
          return true;
        }
        if (valid[RAW_STRING_END]) {
          lexer->mark_end(lexer);
          s->in_raw = false;
          s->raw_fence = 0;
          lexer->result_symbol = RAW_STRING_END;
          return true;
        }
        return false;
      }
      // Not a close — the quote and short fence are content.
      have_content = true;
      continue;
    }
    advance(lexer);
    have_content = true;
  }
  if (have_content && valid[RAW_STRING_CONTENT]) {
    lexer->mark_end(lexer);
    lexer->result_symbol = RAW_STRING_CONTENT;
    return true;
  }
  return false;
}

// ------------------------------------------------------ multiline strings

static bool scan_multiline_content(TSLexer *lexer) {
  bool have_content = false;
  for (;;) {
    if (lexer->eof(lexer)) break;
    int32_t c = lexer->lookahead;
    if (c == '\\' || c == '{') break;   // escape / interpolation
    if (c == '"') {
      // `"""` closes; fewer quotes are content [gram.lex.str.multi].
      lexer->mark_end(lexer);
      uint8_t quotes = 0;
      while (lexer->lookahead == '"' && quotes < 3) {
        quotes++;
        advance(lexer);
      }
      if (quotes >= 3) {
        // Closing delimiter — stop before it (mark_end already set).
        return have_content;
      }
      have_content = true;
      continue;
    }
    advance(lexer);
    have_content = true;
  }
  if (have_content) lexer->mark_end(lexer);
  return have_content;
}

// ------------------------------------------------------------------- driver

bool tree_sitter_wolf_external_scanner_scan(void *payload, TSLexer *lexer,
                                            const bool *valid) {
  Scanner *s = (Scanner *)payload;

  // Error recovery: every symbol is marked valid. Do nothing clever.
  if (valid[ERROR_SENTINEL]) return false;

  if (s->in_raw && (valid[RAW_STRING_CONTENT] || valid[RAW_STRING_END])) {
    return scan_raw_string(s, lexer, valid);
  }

  if (valid[MULTILINE_STRING_CONTENT]) {
    if (scan_multiline_content(lexer)) {
      lexer->result_symbol = MULTILINE_STRING_CONTENT;
      return true;
    }
    // fall through: `"""`/`\`/`{` at start of content — internal lexer's.
  }

  if (valid[RAW_STRING_START]) {
    // The scanner runs before trivia is skipped, so skip intra-line
    // whitespace ourselves — but NEVER a newline: `\n` may be a valid
    // statement terminator token ([gram.lex.newline]) and eating it here
    // would merge statements across lines.
    while (lexer->lookahead == ' ' || lexer->lookahead == '\t' ||
           lexer->lookahead == '\r') {
      lexer->advance(lexer, true);
    }
    if (lexer->lookahead == 'r') return scan_raw_string_start(s, lexer);
  }

  return false;
}
