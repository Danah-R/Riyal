import 'home_data.dart';

class AnalyticsItem {
  const AnalyticsItem(
    this.name,
    this.category,
    this.amount,
    this.days,
    this.group,
  );
  final String name;
  final String category;
  final double amount;
  final int days;
  final String group;
}

// Monthly demo amounts reconcile with the Home overview (950 + 620 + 770).
final analyticsItems = <AnalyticsItem>[
  const AnalyticsItem('Netflix', 'Subscriptions', 45, 3, 'Streaming'),
  const AnalyticsItem('ChatGPT Plus', 'Subscriptions', 80, 10, 'Productivity'),
  const AnalyticsItem('Duolingo', 'Subscriptions', 30, 12, 'Productivity'),
  const AnalyticsItem(
    'Fitness membership',
    'Subscriptions',
    295,
    18,
    'Fitness',
  ),
  const AnalyticsItem(
    'Learning membership',
    'Subscriptions',
    500,
    22,
    'Learning',
  ),
  const AnalyticsItem('Electricity', 'Utilities', 350, 5, 'Electricity'),
  const AnalyticsItem('Home internet', 'Utilities', 200, 8, 'Internet'),
  const AnalyticsItem('Water', 'Utilities', 70, 16, 'Water'),
  const AnalyticsItem('Housekeeper allowance', 'Staff', 500, 2, 'Household'),
  const AnalyticsItem('Driver allowance', 'Staff', 270, 7, 'Transport'),
];

// Combined budget is independent of category caps.
const overallAnalyticsBudget = 3000.0;
const analyticsBudgets = {
  'Subscriptions': subscriptionsBudget,
  'Utilities': 800.0,
  'Staff': 1000.0,
};
const analyticsHistory = <String, List<double>>{
  'Subscriptions': [760, 820, 850, 880, 900, subscriptionsSpent],
  'Utilities': [500, 540, 580, 560, 600, 620],
  'Staff': [650, 650, 700, 720, 700, 770],
};
