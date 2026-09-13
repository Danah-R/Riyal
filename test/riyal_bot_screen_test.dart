import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:riyal/screens/riyal_bot_screen.dart';
import 'package:riyal/services/gemini_api.dart';
import 'package:riyal/services/riyal_bot_prompt.dart';

void main() {
  testWidgets('Riyal Bot sends Arabic and renders the response with RTL', (
    tester,
  ) async {
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map;
      expect(body['systemInstruction']['parts'][0]['text'], riyalBotPrompt);
      expect(body['contents'][0]['parts'][0]['text'], 'كيف أوفر؟');
      return http.Response(
        jsonEncode({
          'candidates': [
            {
              'finishReason': 'STOP',
              'content': {
                'parts': [
                  {'text': 'ابدئي بتحديد ميزانية شهرية.'},
                ],
              },
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final api = GeminiApi(
      apiKey: 'test-key',
      model: 'test-model',
      client: client,
      systemInstruction: riyalBotPrompt,
    );
    await tester.pumpWidget(MaterialApp(home: RiyalBotScreen(api: api)));
    await tester.enterText(find.byType(TextField), 'كيف أوفر؟');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(find.text('ابدئي بتحديد ميزانية شهرية.'), findsOneWidget);
    final answer = tester.widget<EditableText>(
      find.text('ابدئي بتحديد ميزانية شهرية.'),
    );
    expect(answer.textDirection, TextDirection.rtl);
    await tester.tap(find.byTooltip('New chat'));
    await tester.pumpAndSettle();
    expect(api.history, isEmpty);
    await tester.pumpWidget(const SizedBox());
    api.dispose();
    client.close();
  });
}


