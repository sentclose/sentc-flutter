import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tests/user_test.dart' as user_tests;
import 'tests/user_tests_2.dart' as user_tests_2;
import 'tests/group_tests_1.dart' as group_tests_1;
import 'tests/group_tests_2.dart' as group_tests_2;
import 'tests/searchable_tests.dart' as searchable_tests;
import 'tests/sortable_tests.dart' as sortable_tests_1;
import 'tests/sortable_tests_2.dart' as sortable_tests_2;
import 'tests/file_test.dart' as file_tests;
import 'tests/file_test_user.dart' as file_tests_user;

void main() async {
  await dotenv.load(fileName: ".env");

  group("user tests", user_tests.main);

  group("user tests 2", user_tests_2.main);

  group("group tests 1", group_tests_1.main);

  group("group tests 2", group_tests_2.main);

  group("searchable test", searchable_tests.main);

  group("sortable test 1", sortable_tests_1.main);

  group("sortable test 2", sortable_tests_2.main);

  group("file tests", file_tests.main);

  group("file tests user", file_tests_user.main);
}
