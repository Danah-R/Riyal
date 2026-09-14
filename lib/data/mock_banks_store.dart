import 'mock_bank.dart';
import 'supabase_config.dart';

/// The fixed catalog of fake banks shown on the "choose your bank" grid.
/// Loaded once and cached — the list never changes at runtime.
class MockBanksStore {
  MockBanksStore._();
  static final instance = MockBanksStore._();

  List<MockBank>? _cached;

  Future<List<MockBank>> load() async {
    final cached = _cached;
    if (cached != null) return cached;
    final rows = await supabase
        .from('mock_banks')
        .select()
        .order('sort_order');
    final banks = rows.map(MockBank.fromRow).toList();
    _cached = banks;
    return banks;
  }
}
