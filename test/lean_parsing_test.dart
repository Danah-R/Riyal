import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/bank_account.dart';
import 'package:riyal/data/bank_transaction.dart';

void main() {
  group('BankTransaction.fromLeanJson', () {
    test('parses the documented {status, payload: {transactions}} shape', () {
      final json = {
        'status': 'OK',
        'payload': {
          'transactions': [
            {
              'id': 'tx-1',
              'description': 'NETFLIX.COM',
              'amount': 45,
              'currency_code': 'SAR',
              'timestamp': '2026-01-15T00:00:00Z',
            },
          ],
        },
      };

      final result = BankTransaction.fromLeanJson(
        entityId: 'entity-1',
        json: json,
      );

      expect(result, hasLength(1));
      expect(result.single.id, 'tx-1');
      expect(result.single.description, 'NETFLIX.COM');
      expect(result.single.amount, 45);
    });

    test('also accepts a bare top-level list', () {
      final json = [
        {
          'id': 'tx-2',
          'description': 'SPOTIFY AB',
          'amount': -25,
          'date': '2026-02-01T00:00:00Z',
        },
      ];

      final result = BankTransaction.fromLeanJson(
        entityId: 'entity-1',
        json: json,
      );

      expect(result.single.amount, 25); // sign normalized to positive
    });

    test('skips entries missing required fields instead of crashing', () {
      final json = {
        'transactions': [
          {'id': 'tx-3'}, // missing description/amount/date
        ],
      };

      expect(BankTransaction.fromLeanJson(entityId: 'e', json: json), isEmpty);
    });
  });

  group('BankAccount.fromSupabaseRow', () {
    // The Lean-JSON -> Postgres-row mapping itself now lives in the Edge
    // Function (supabase/functions/_shared/parsing.ts, TypeScript/Deno —
    // not reachable from Dart tests). This just covers the Dart side:
    // reading a `bank_accounts` row back into a [BankAccount].
    test('maps a Postgres row', () {
      final account = BankAccount.fromSupabaseRow({
        'entity_id': 'entity-1',
        'account_id': 'acc-1',
        'bank_name': 'Saudi National Bank',
        'masked_account_number': '•••• 7519',
        'status': 'connected',
        'last_synced_at': '2026-01-15T00:00:00.000Z',
        'error_message': null,
      });

      expect(account.entityId, 'entity-1');
      expect(account.accountId, 'acc-1');
      expect(account.bankName, 'Saudi National Bank');
      expect(account.maskedAccountNumber, '•••• 7519');
      expect(account.status, BankAccountStatus.connected);
      expect(account.lastSyncedAt, isNotNull);
    });

    test('falls back to error status for an unrecognized status value', () {
      final account = BankAccount.fromSupabaseRow({
        'entity_id': 'entity-1',
        'bank_name': 'Some Bank',
        'masked_account_number': '•••• 0000',
        'status': 'something_unexpected',
      });

      expect(account.status, BankAccountStatus.error);
    });
  });
}
