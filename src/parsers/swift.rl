/************************* Required for every parser *************************/
#ifndef OHCOUNT_SWIFT_PARSER_H
#define OHCOUNT_SWIFT_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *SWIFT_LANG = LANG_SWIFT;

// the languages entities
const char *swift_entities[] = {
  "space", "comment", "any"
};

// constants associated with the entities
enum {
  SWIFT_SPACE = 0, SWIFT_COMMENT, SWIFT_ANY
};

/*****************************************************************************/

%%{
  machine swift;
  write data;
  include common "common.rl";

  # Line counting machine

  action swift_ccallback {
    switch(entity) {
    case SWIFT_SPACE:
      ls
      break;
    case SWIFT_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(SWIFT_LANG)
      break;
    case NEWLINE:
      std_newline(SWIFT_LANG)
    }
  }

  swift_line_comment =
    '//' @comment (
      escaped_newline %{ entity = INTERNAL_NL; } %swift_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )*;
  swift_block_comment =
    '/*' @comment (
      newline %{ entity = INTERNAL_NL; } %swift_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '*/';
  swift_comment = swift_line_comment | swift_block_comment;

  swift_line := |*
    spaces    ${ entity = SWIFT_SPACE; } => swift_ccallback;
    swift_comment;
    newline   ${ entity = NEWLINE; } => swift_ccallback;
    ^space    ${ entity = SWIFT_ANY;   } => swift_ccallback;
  *|;

  action swift_ecallback {
    callback(SWIFT_LANG, swift_entities[entity], cint(ts), cint(te), userdata);
  }

  swift_line_comment_entity = '//' (escaped_newline | nonnewline)*;
  swift_block_comment_entity = '/*' any* :>> '*/';
  swift_comment_entity = swift_line_comment_entity | swift_block_comment_entity;

  swift_entity := |*
    space+                 ${ entity = SWIFT_SPACE;      } => swift_ecallback;
    swift_comment_entity    ${ entity = SWIFT_COMMENT;    } => swift_ecallback;
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with swift code.
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
void parse_swift(char *buffer, int length, int count,
             void (*callback) (const char *lang, const char *entity, int s,
                               int e, void *udata),
             void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? swift_en_swift_line : swift_en_swift_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(SWIFT_LANG) }
}

#endif

/*****************************************************************************/
