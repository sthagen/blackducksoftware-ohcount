void test_swift_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("swift", " //comment"),
    "swift", "", "//comment", 0
  );
}

void test_swift_empty_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("swift", " //\n"),
    "swift", "", "//\n", 0
  );
}

void test_swift_block_comment() {
  test_parser_verify_parse(
    test_parser_sourcefile("swift", "/*comment*/"),
    "swift", "", "/*comment*/", 0
  );
}

void test_swift_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("swift", " //comment"),
    "comment", "//comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("c", " /*comment*/"),
    "comment", "/*comment*/"
  );
}

void all_swift_tests() {
  test_swift_comments();
  test_swift_empty_comments();
  test_swift_block_comment();
  test_swift_comment_entities();
}
