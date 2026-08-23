class FinanceTransaction {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final DateTime date;

  const FinanceTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

class FinanceOverview {
  final double totalIncome;
  final double totalExpenses;
  final List<FinanceTransaction> transactions;

  const FinanceOverview({
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactions,
  });

  static const empty = FinanceOverview(
    totalIncome: 0,
    totalExpenses: 0,
    transactions: [],
  );

  double get balance => totalIncome - totalExpenses;
}
