// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tests/user_tests.dart' as user_tests;
import 'tests/group_tests_1.dart' as group_tests_1;
import 'tests/group_tests_2.dart' as group_tests_2;

void main() async {
  await dotenv.load(fileName: ".env");

  group("user tests", user_tests.main);
  group("group tests 1", group_tests_1.main);
  group("group tests 2", group_tests_2.main);
}
