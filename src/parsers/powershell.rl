/************************* Required for every parser *************************/
#ifndef OHCOUNT_POWERSHELL_PARSER_H
#define OHCOUNT_POWERSHELL_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *POWERSHELL_LANG = LANG_POWERSHELL;

// the languages entities
const char *powershell_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  POWERSHELL_SPACE = 0, POWERSHELL_COMMENT, POWERSHELL_STRING, POWERSHELL_ANY
};

/*****************************************************************************/

%%{
  machine powershell;
  write data;
  include common "common.rl";

  # Line counting machine

  action powershell_ccallback {
    switch(entity) {
    case POWERSHELL_SPACE:
      ls
      break;
    case POWERSHELL_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(POWERSHELL_LANG)
      break;
    case NEWLINE:
      std_newline(POWERSHELL_LANG)
    }
  }

  powershell_line_comment = '#' @comment nonnewline*;
  powershell_block_comment =
    '<#' @comment (
      newline %{ entity = INTERNAL_NL; } %powershell_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '#>';
  powershell_comment = powershell_line_comment | powershell_block_comment;

  powershell_sq_str =
    '\'' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %powershell_ccallback
      |
      '\\' newline %{ entity = INTERNAL_NL; } %powershell_ccallback
      |
      ws
      |
      [^\r\n\f\t '\\] @code
      |
      '\\' nonnewline @code
    )* '\'' @commit;
  powershell_dq_str =
    '"' @enqueue @code (
      newline %{ entity = INTERNAL_NL; } %powershell_ccallback
      |
      '\\' newline %{ entity = INTERNAL_NL; } %powershell_ccallback
      |
      ws
      |
      [^\r\n\f\t "\\] @code
      |
      '\\' nonnewline @code
    )* '"' @commit;
  # TODO: heredoc; see ruby.rl for details.
  powershell_string = powershell_sq_str | powershell_dq_str;

  powershell_line := |*
    spaces         ${ entity = POWERSHELL_SPACE; } => powershell_ccallback;
    powershell_comment;
    powershell_string;
    newline        ${ entity = NEWLINE;     } => powershell_ccallback;
    ^space         ${ entity = POWERSHELL_ANY;   } => powershell_ccallback;
  *|;

  # Entity machine

  action powershell_ecallback {
    callback(POWERSHELL_LANG, powershell_entities[entity], cint(ts), cint(te), userdata);
  }

  powershell_line_comment_entity = '#' nonnewline*;
  powershell_block_comment_entity = '<#' any* :>> '#>';
  powershell_comment_entity = powershell_line_comment_entity | powershell_block_comment_entity;

  powershell_entity := |*
    space+                    ${ entity = POWERSHELL_SPACE;   } => powershell_ecallback;
    powershell_comment_entity ${ entity = POWERSHELL_COMMENT; } => powershell_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with powershell code.
 *
 * @param *buffer The string to parse.
 * @param length The length of the string to parse.
 * @param count Integer flag specifying whether or not to count lines. If yes,
 *   uses the Ragel machine optimized for counting. Otherwise uses the Ragel
 *   machine optimized for returning entity positions.
 * @param *callback Callback function. If count is set, callback is called for
 *   every line of code, comment, or blank with 'lcode', 'lcomment', and
 *   'lblank' respectively. Otherwise callback is called for each entity found.
 */
void parse_powershell(char *buffer, int length, int count,
                 void (*callback) (const char *lang, const char *entity, int s,
                                   int e, void *udata),
                 void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? powershell_en_powershell_line : powershell_en_powershell_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(POWERSHELL_LANG) }
}

#endif

/*****************************************************************************/
