import 'package:flutter_test/flutter_test.dart';

import 'tests/user_test.dart' as user_tests;
import 'tests/group_tests_1.dart' as group_tests_1;
import 'tests/file_test.dart' as file_tests;

void main() {
  group("user tests", user_tests.main);

  group("group tests 1", group_tests_1.main);

  group("file tests", file_tests.main);
}
