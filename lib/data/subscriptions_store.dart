import 'package:flutter/foundation.dart';

import 'subscription.dart';
import 'subscription_category.dart';

class SubscriptionsStore {
  SubscriptionsStore._() : subscriptions = ValueNotifier<List<Subscription>>(_seed());

  static final SubscriptionsStore instance = SubscriptionsStore._();

  final ValueNotifier<List<Subscription>> subscriptions;

  void add(Subscription subscription) {
    subscriptions.value = [...subscriptions.value, subscription];
  }

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
