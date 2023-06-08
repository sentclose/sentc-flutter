import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tests/user_test.dart' as user_tests;
import 'tests/group_tests_1.dart' as group_tests_1;
import 'tests/group_tests_2.dart' as group_tests_2;
import 'tests/file_test.dart' as file_tests;

void main() async {
  await dotenv.load(fileName: ".env");

  group("user tests", user_tests.main);

  group("group tests 1", group_tests_1.main);

  group("group tests 2", group_tests_2.main);

  group("file tests", file_tests.main);
}
