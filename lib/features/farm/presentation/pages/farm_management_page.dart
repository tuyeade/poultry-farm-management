import 'package:flutter/material.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../batches/presentation/pages/batch_list_page.dart';
import '../../../inventory/presentation/pages/egg_inventory_page.dart';
import '../../../production/presentation/pages/daily_production_page.dart';
import '../../../feed/presentation/pages/feed_management_page.dart';
import '../../../medicine/presentation/pages/medicines_page.dart';
import '../../../vaccination/presentation/pages/vaccinations_page.dart';
import '../../data/models/farm_overview.dart';
import '../../data/repositories/farm_repository.dart';
import '../widgets/farm_header.dart';
import '../widgets/farm_management_card.dart';

class FarmManagementPage extends StatefulWidget {
  const FarmManagementPage({super.key});

  @override
  State<FarmManagementPage> createState() => _FarmManagementPageState();
}

class _FarmManagementPageState extends State<FarmManagementPage> {
  final FarmRepository _repository = FarmRepository();
  late Future<FarmOverview> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  void _loadOverview() {
    _overviewFuture = _repository.getOverview();
  }

  Future<void> _retry() async {
    setState(_loadOverview);
    await _overviewFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n.farmManagement,
          style: AppTextStyles.heading3.copyWith(color: AppColors.textLight),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<FarmOverview>(
          future: _overviewFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.unableToLoadFarmInformation(
                          snapshot.error.toString(),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            final overview = snapshot.data ?? FarmOverview.empty;
            return RefreshIndicator(
              onRefresh: _retry,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FarmHeader(
                      farmName: overview.farmName,
                      totalBirds: overview.totalBirds.toString(),
                      activeBatches: overview.activeBatches.toString(),
                      mortalityRate: overview.mortalityRate,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.farmOverview,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        FarmManagementCard(
                          icon: Icons.pets_outlined,
                          title: l10n.chickenBatches,
                          value: l10n.activeCount(overview.activeBatches),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BatchListPage(),
                              ),
                            );
                            if (mounted) _retry();
                          },
                        ),
                        FarmManagementCard(
                          icon: Icons.egg_outlined,
                          title: l10n.dailyProduction,
                          value: l10n.eggsToday(overview.eggsToday),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DailyProductionPage(),
                              ),
                            );
                            if (mounted) _retry();
                          },
                        ),
                        FarmManagementCard(
                          icon: Icons.inventory_2_outlined,
                          title: l10n.eggInventoryTitle,
                          value: l10n.availableCount(overview.eggInventory),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EggInventoryPage(),
                              ),
                            );
                            if (mounted) _retry();
                          },
                        ),
                        FarmManagementCard(
                          icon: Icons.grass_outlined,
                          title: l10n.feedManagement,
                          value: l10n.kgStock(
                            overview.feedStock.toStringAsFixed(1),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FeedManagementPage(),
                              ),
                            );
                            if (mounted) _retry();
                          },
                        ),
                        FarmManagementCard(
                          icon: Icons.medication_outlined,
                          title: l10n.medicines,
                          value: l10n.recordsCount(overview.medicineCount),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MedicinesPage(),
                              ),
                            );
                            if (mounted) _retry();
                          },
                        ),
                        FarmManagementCard(
                          icon: Icons.vaccines_outlined,
                          title: l10n.vaccinations,
                          value: l10n.recordsCount(overview.vaccinationCount),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VaccinationsPage(),
                              ),
                            );
                            if (mounted) _retry();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
