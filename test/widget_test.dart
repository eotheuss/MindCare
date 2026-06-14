import 'package:flutter_test/flutter_test.dart';

import 'package:mindcare/main.dart';

void main() {
  testWidgets('MindCare starts on welcome screen', (tester) async {
    await tester.pumpWidget(const MindCareApp());

    expect(find.text('Bem Vindo!'), findsOneWidget);
    expect(find.text('MindCare'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });
}
