import 'package:flutter/foundation.dart';

import 'device_id_store.dart';
import 'subscription.dart';
import 'subscription_category.dart';
import 'supabase_config.dart';
import 'tracked_category.dart';

/// Backed by the Supabase `subscriptions` table (see
/// supabase/migrations/0001_init.sql) instead of an in-memory list — a
/// first run for a device seeds the same demo subscriptions the app
/// always shipped with, then persists them so they're stable afterwards.
class SubscriptionsStore {
  SubscriptionsStore._();

  static final SubscriptionsStore instance = SubscriptionsStore._();

  final ValueNotifier<List<Subscription>> subscriptions =
      ValueNotifier<List<Subscription>>([]);

  Future<void> load() async {
    final deviceId = await DeviceIdStore.instance.getOrCreateDeviceId();
    final rows = await supabase
        .from('subscriptions')
        .select()
        .eq('device_id', deviceId)
        .order('created_at');

    if (rows.isEmpty) {
      final seeded = _seed();
      for (final subscription in seeded) {
        await _insert(deviceId, subscription);
      }
      subscriptions.value = seeded;
      return;
    }

    subscriptions.value = rows.map(_fromRow).toList();
  }

  /// Updates the in-memory list immediately (callers don't await this), and
  /// persists in the background — a persistence failure shouldn't crash an
  /// unrelated caller that fired this off without awaiting it.
  Future<void> add(Subscription subscription) async {
    subscriptions.value = [...subscriptions.value, subscription];
    try {
      final deviceId = await DeviceIdStore.instance.getOrCreateDeviceId();
      await _insert(deviceId, subscription);
    } catch (error) {
      debugPrint('Subscription persist failed: $error');
    }
  }

  Future<void> _insert(String deviceId, Subscription subscription) {
    return supabase.from('subscriptions').insert({
      'device_id': deviceId,
      'name': subscription.name,
      'logo_asset': subscription.logoAsset,
      'amount': subscription.amount,
      'cycle': subscription.cycle.name,
      'next_billing_date': subscription.nextBillingDate
          .toIso8601String()
          .split('T')
          .first,
      'category_key': subscription.category.key,
    });
  }

  Subscription _fromRow(Map<String, dynamic> row) => Subscription(
    name: row['name'] as String,
    logoAsset: row['logo_asset'] as String?,
    amount: (row['amount'] as num).toDouble(),
    cycle: BillingCycle.values.byName(row['cycle'] as String),
    nextBillingDate: DateTime.parse(row['next_billing_date'] as String),
    category: _categoryFromKey(row['category_key'] as String),
  );

  TrackedCategory _categoryFromKey(String key) =>
      SubscriptionCategories.values.firstWhere(
        (c) => c.key == key,
        orElse: () => SubscriptionCategories.other,
      );

  static List<Subscription> _seed() {
    final now = DateTime.now();
    return [
      Subscription(
        name: 'Netflix',
        logoAsset: 'lib/assets/logos/Netflix_icon.svg',
        amount: 45,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 3)),
        category: SubscriptionCategories.entertainment,
      ),
      Subscription(
        name: 'ChatGPT Plus',
        logoAsset:
            'lib/assets/logos/chatgpt-logo-chat-gpt-icon-on-white-background-free-vector.jpg',
        amount: 80,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 10)),
        category: SubscriptionCategories.ai,
      ),
      Subscription(
        name: 'Duolingo',
        logoAsset: 'lib/assets/logos/doulingo.webp',
        amount: 30,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 12)),
        category: SubscriptionCategories.education,
      ),
      Subscription(
        name: 'Spotify',
        logoAsset: 'lib/assets/logos/Spotify_App_Logo.svg.webp',
        amount: 25,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 18)),
        category: SubscriptionCategories.entertainment,
      ),
      Subscription(
        name: 'Adobe Creative Cloud',
        logoAsset: 'lib/assets/logos/Adobe_Creative_Cloud_rainbow_icon.svg',
        amount: 249,
        cycle: BillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 22)),
        category: SubscriptionCategories.productivity,
      ),
    ];
  }
}
