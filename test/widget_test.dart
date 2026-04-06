import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jlpt_study_app2/main.dart';

void main() {
  testWidgets('Quiz app loads scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
