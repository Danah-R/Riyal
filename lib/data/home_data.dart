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

const subscriptionsSpent = 950.0;
const subscriptionsBudget = 2000.0;

const overview = [
  SpendingCategory(label: 'Subscriptions', amount: 950, color: 0xFF6FBF9A),
  SpendingCategory(label: 'Utilities', amount: 620, color: 0xFF8FA85E),
  SpendingCategory(label: 'Staff', amount: 770, color: 0xFF4B4630),
];
