class ReportEntry {
  final String title;
  final String subtitle;
  final String value;
  final DateTime date;

  const ReportEntry({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.date,
  });
}

class MonthlyReport {
  final String label;
  final double income;
  final double expenses;
  final int eggs;

  const MonthlyReport({
    required this.label,
    required this.income,
    required this.expenses,
    required this.eggs,
  });
}

class ReportOverview {
  final double totalIncome;
  final double totalExpenses;
  final int totalEggs;
  final int totalChickens;
  final Map<String, List<ReportEntry>> details;
  final List<MonthlyReport> monthly;
  final Map<String, double> revenueBreakdown;
  final double mortalityRate;

  const ReportOverview({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalEggs,
    required this.totalChickens,
    required this.details,
    required this.monthly,
    required this.revenueBreakdown,
    required this.mortalityRate,
  });

  static const empty = ReportOverview(
    totalIncome: 0,
    totalExpenses: 0,
    totalEggs: 0,
    totalChickens: 0,
    details: {},
    monthly: [],
    revenueBreakdown: {},
    mortalityRate: 0,
  );
  double get netProfit => totalIncome - totalExpenses;
}
