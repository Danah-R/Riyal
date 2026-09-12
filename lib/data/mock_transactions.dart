import 'subscription_category.dart';
import 'tracked_category.dart';

class MockTransaction {
  const MockTransaction({
    required this.merchant,
    required this.amount,
    required this.daysAgo,
    this.matchedName,
    this.matchedLogo,
    this.matchedCategory,
  });

  final String merchant;
  final double amount;
  final int daysAgo;
  final String? matchedName;
  final String? matchedLogo;
  final TrackedCategory? matchedCategory;
}

const List<MockTransaction> recentTransactions = [
  MockTransaction(
    merchant: 'NETFLIX.COM',
    amount: 45,
    daysAgo: 27,
    matchedName: 'Netflix',
    matchedLogo: 'lib/assets/logos/Netflix_icon.svg',
    matchedCategory: SubscriptionCategories.entertainment,
  ),
  MockTransaction(
    merchant: 'OPENAI *CHATGPT SUBSCR',
    amount: 80,
    daysAgo: 20,
    matchedName: 'ChatGPT Plus',
    matchedLogo:
        'lib/assets/logos/chatgpt-logo-chat-gpt-icon-on-white-background-free-vector.jpg',
    matchedCategory: SubscriptionCategories.ai,
  ),
  MockTransaction(
    merchant: 'SPOTIFY AB',
    amount: 25,
    daysAgo: 15,
    matchedName: 'Spotify',
    matchedLogo: 'lib/assets/logos/Spotify_App_Logo.svg.webp',
    matchedCategory: SubscriptionCategories.entertainment,
  ),
  MockTransaction(
    merchant: 'AMAZON PRIME VIDEO',
    amount: 20,
    daysAgo: 9,
    matchedName: 'Amazon Prime Video',
    matchedLogo: 'lib/assets/logos/Amazon-Prime-Video-Logo-PNG-Cutout-thumb.webp',
    matchedCategory: SubscriptionCategories.entertainment,
  ),
  MockTransaction(
    merchant: 'STC PAY RECURRING',
    amount: 120,
    daysAgo: 6,
    matchedName: 'STC',
    matchedLogo: 'lib/assets/logos/stc.jpeg',
    matchedCategory: SubscriptionCategories.other,
  ),
  MockTransaction(
    merchant: 'CARREFOUR HYPERMARKET',
    amount: 214,
    daysAgo: 2,
  ),
];
