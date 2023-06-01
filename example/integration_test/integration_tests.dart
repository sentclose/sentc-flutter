import 'package:flutter_test/flutter_test.dart';

import 'tests/user_test.dart' as user_tests;
import 'tests/file_test.dart' as file_tests;

void main() {
  group("user tests", user_tests.main);

  group("file tests", file_tests.main);
}