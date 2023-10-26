void test_powershell_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("powershell", " #comment"),
    "powershell", "", "#comment", 0
  );
}

void test_powershell_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("powershell", " #comment"),
    "comment", "#comment"
  );
}

void all_powershell_tests() {
  test_powershell_comments();
  test_powershell_comment_entities();
}
