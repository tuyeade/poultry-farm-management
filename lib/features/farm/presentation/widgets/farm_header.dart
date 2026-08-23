// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:poultry_farm_management/core/extensions/color_extension.dart';
import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class FarmHeader extends StatelessWidget {
  final String farmName;
  final String totalBirds;
  final String activeBatches;
  final String mortalityRate;
  final VoidCallback? onEdit;

  const FarmHeader({
    super.key,
    required this.farmName,
    required this.totalBirds,
    required this.activeBatches,
    required this.mortalityRate,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  farmName,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.textLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _FarmStatistic(
                  icon: Icons.pets_outlined,
                  value: totalBirds,
                  label: l10n.totalBirdsLabel,
                ),
              ),

              _buildDivider(),

              Expanded(
                child: _FarmStatistic(
                  icon: Icons.inventory_2_outlined,
                  value: activeBatches,
                  label: l10n.activeBatches,
                ),
              ),

              _buildDivider(),

              Expanded(
                child: _FarmStatistic(
                  icon: Icons.analytics_outlined,
                  value: mortalityRate,
                  label: l10n.mortalityRate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 55,
      width: 1,
      color: AppColors.textLight.withValues(alpha: 0.25),
    );
  }
}

class _FarmStatistic extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _FarmStatistic({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textLight, size: 20),

          const SizedBox(height: 7),

          Text(
            value,
            style: AppTextStyles.statisticNumber.copyWith(
              color: AppColors.textLight,
              fontSize: 21,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
