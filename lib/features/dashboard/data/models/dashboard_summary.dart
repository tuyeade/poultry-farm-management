class DashboardActivity {
  final String title;
  final String subtitle;
  final DateTime date;

  const DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.date,
  });
}

class DashboardSummary {
  final int totalBirds;
  final int activeFarms;
  final int eggsToday;
  final double feedRemaining;
  final int eggInventory;
  final double incomeToday;
  final double expensesToday;
  final List<int> eggsLastSevenDays;
  final List<DashboardActivity> recentActivities;

  const DashboardSummary({
    required this.totalBirds,
    required this.activeFarms,
    required this.eggsToday,
    required this.feedRemaining,
    required this.eggInventory,
    required this.incomeToday,
    required this.expensesToday,
    required this.eggsLastSevenDays,
    required this.recentActivities,
  });

  static const empty = DashboardSummary(
    totalBirds: 0,
    activeFarms: 0,
    eggsToday: 0,
    feedRemaining: 0,
    eggInventory: 0,
    incomeToday: 0,
    expensesToday: 0,
    eggsLastSevenDays: [0, 0, 0, 0, 0, 0, 0],
    recentActivities: [],
  );

  double get profitToday => incomeToday - expensesToday;
}
