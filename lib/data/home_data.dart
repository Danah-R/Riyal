class SpendingCategory {
  const SpendingCategory({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final int color;
}

class Renewal {
  const Renewal({
    required this.name,
    required this.iconAsset,
    required this.renewsInDays,
    required this.amount,
  });

  final String name;
  final String iconAsset;
  final int renewsInDays;
  final double amount;
}

const subscriptionsSpent = 950.0;
const subscriptionsBudget = 2000.0;

const overview = [
  SpendingCategory(label: 'Subscriptions', amount: 950, color: 0xFF6FBF9A),
  SpendingCategory(label: 'Utilities', amount: 620, color: 0xFF8FA85E),
  SpendingCategory(label: 'Staff', amount: 770, color: 0xFF4B4630),
];

const upcomingRenewals = [
  Renewal(
    name: 'Netflix',
    iconAsset: 'assets/icons/netflix.svg',
    renewsInDays: 3,
    amount: 45,
  ),
  Renewal(
    name: 'ChatGPT Plus',
    iconAsset: 'assets/icons/chatgpt.svg',
    renewsInDays: 10,
    amount: 80,
  ),
  Renewal(
    name: 'Duolingo',
    iconAsset: 'assets/icons/duolingo.svg',
    renewsInDays: 12,
    amount: 30,
  ),
];
