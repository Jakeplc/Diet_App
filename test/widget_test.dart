// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:diet_app/main.dart';
import 'dart:io';

import 'package:diet_app/services/storage_service.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('diet_app_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(StorageService.userBox);
    await Hive.openBox(StorageService.foodItemsBox);
    await Hive.openBox(StorageService.foodLogsBox);
    await Hive.openBox(StorageService.weightLogsBox);
    await Hive.openBox(StorageService.mealPlansBox);
    await Hive.openBox(StorageService.waterLogsBox);
    await Hive.openBox(StorageService.glpLogsBox);
    await Hive.openBox(StorageService.settingsBox);
    await Hive.openBox(StorageService.recipesBox);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const DietApp());
    expect(find.byType(DietApp), findsOneWidget);
  });
}
