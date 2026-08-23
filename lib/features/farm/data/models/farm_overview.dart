class FarmOverview {
  final String farmName;
  final int totalBirds;
  final int activeBatches;
  final int mortalityCount;
  final int initialBirds;
  final int eggsToday;
  final int eggInventory;
  final double feedStock;
  final int medicineCount;
  final int vaccinationCount;

  const FarmOverview({
    required this.farmName,
    required this.totalBirds,
    required this.activeBatches,
    required this.mortalityCount,
    required this.initialBirds,
    required this.eggsToday,
    required this.eggInventory,
    required this.feedStock,
    required this.medicineCount,
    required this.vaccinationCount,
  });

  static const empty = FarmOverview(
    farmName: 'No farm configured',
    totalBirds: 0,
    activeBatches: 0,
    mortalityCount: 0,
    initialBirds: 0,
    eggsToday: 0,
    eggInventory: 0,
    feedStock: 0,
    medicineCount: 0,
    vaccinationCount: 0,
  );

  String get mortalityRate {
    if (initialBirds <= 0) return '0%';
    return '${(mortalityCount / initialBirds * 100).toStringAsFixed(1)}%';
  }
}
