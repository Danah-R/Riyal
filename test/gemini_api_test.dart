import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:riyal/services/gemini_api.dart';

void main() {
  test(
    'Sends text, returns Arabic and carries successful conversation turns',
    () async {
      var calls = 0;
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map;
        expect(request.headers['x-goog-api-key'], 'test-key');
        expect(request.url.query, isEmpty);
        expect((body['contents'] as List).length, calls == 0 ? 1 : 3);
        calls++;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'finishReason': 'STOP',
                'content': {
                  'parts': [
                    {'text': 'أهلًا بك'},
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
      );
      expect(await api.sendMessage('مرحبا'), 'أهلًا بك');
      await api.sendMessage('ساعدني');
      expect(api.history.length, 4);
      api.clearHistory();
      expect(api.history, isEmpty);
      api.dispose();
      client.close();
    },
  );
  test('Rate limits and empty responses do not contaminate history', () async {
    var calls = 0;
    final client = MockClient(
      (_) async => ++calls == 1
          ? http.Response('secret-test-key', 429)
          : http.Response('{}', 200),
    );
    final api = GeminiApi(
      apiKey: 'test-key',
      model: 'test-model',
      client: client,
    );
    await expectLater(
      api.sendMessage('Hello'),
      throwsA(
        isA<GeminiApiException>().having((e) => e.statusCode, 'status', 429),
      ),
    );
    await expectLater(
      api.sendMessage('Hello'),
      throwsA(isA<GeminiApiException>()),
    );
    expect(api.history, isEmpty);
    api.dispose();
    client.close();
  });
}
