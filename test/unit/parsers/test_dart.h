void test_dart_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("dart", " //comment"),
    "dart", "", "//comment", 0
  );
}

void test_dart_empty_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("dart", " //\n"),
    "dart", "", "//\n", 0
  );
}

void test_dart_block_comment() {
  test_parser_verify_parse(
    test_parser_sourcefile("dart", "/*comment*/"),
    "dart", "", "/*comment*/", 0
  );
}

void test_dart_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("dart", " //comment"),
    "comment", "//comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("c", " /*comment*/"),
    "comment", "/*comment*/"
  );
}

void all_dart_tests() {
  test_dart_comments();
  test_dart_empty_comments();
  test_dart_block_comment();
  test_dart_comment_entities();
}
