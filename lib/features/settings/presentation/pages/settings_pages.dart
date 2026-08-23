import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/language_provider.dart';

import 'profile_page.dart';
import 'security_page.dart';
import 'farm_settings_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          30,
        ),
        children: [
          // --------------------------------------------------
          // ACCOUNT
          // --------------------------------------------------

          _sectionTitle(l10n.account),

          _settingCard(
            context,
            icon: Icons.person_outline,
            title: l10n.profile,
            subtitle: l10n.managePersonalInformation,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),

          _settingCard(
            context,
            icon: Icons.lock_outline,
            title: l10n.security,
            subtitle: l10n.passwordAndAccountSecurity,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SecurityPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // FARM
          // --------------------------------------------------

          _sectionTitle(l10n.farm),

          _settingCard(
            context,
            icon: Icons.agriculture_outlined,
            title: l10n.farmSettings,
            subtitle: l10n.manageFarmInformation,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FarmSettingsPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // PREFERENCES
          // --------------------------------------------------

          _sectionTitle(l10n.preferences),

          _settingCard(
            context,
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: currentLocale.languageCode == 'am'
                ? l10n.amharic
                : l10n.english,
            onTap: () {
              _showLanguageDialog(context, ref);
            },
          ),

          _settingCard(
            context,
            icon: Icons.notifications_none_outlined,
            title: l10n.notifications,
            subtitle: l10n.manageNotifications,
            onTap: () {
              _showComingSoon(context);
            },
          ),

          _settingCard(
            context,
            icon: Icons.dark_mode_outlined,
            title: l10n.appearance,
            subtitle: l10n.lightMode,
            onTap: () {
              _showComingSoon(context);
            },
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // ABOUT
          // --------------------------------------------------

          _sectionTitle(l10n.about),

          _settingCard(
            context,
            icon: Icons.info_outline,
            title: l10n.about,
            subtitle: l10n.poultryFarmManagement,
            onTap: () {
              _showAboutDialog(context);
            },
          ),

          _settingCard(
            context,
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            subtitle: l10n.learnHowYourDataIsHandled,
            onTap: () {
              _showComingSoon(context);
            },
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // SIGN OUT
          // --------------------------------------------------

          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                _showSignOutDialog(context);
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.signOut),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(
                    alpha: 0.5,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              l10n.poultryFarmManagement,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              'Version 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 8,
      ),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ==========================================================
  // SETTING CARD
  // ==========================================================

  Widget _settingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ==========================================================
  // LANGUAGE
  // ==========================================================

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentLocale = ref.read(languageProvider);

    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;

        return AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text(
                  '🇬🇧',
                  style: TextStyle(fontSize: 24),
                ),
                title: Text(l10n.english),
                trailing: currentLocale.languageCode == 'en'
                    ? const Icon(
                        Icons.check,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  ref
                      .read(languageProvider.notifier)
                      .setLanguage('en');

                  Navigator.pop(dialogContext);
                },
              ),

              ListTile(
                leading: const Text(
                  '🇪🇹',
                  style: TextStyle(fontSize: 24),
                ),
                title: Text(l10n.amharic),
                trailing: currentLocale.languageCode == 'am'
                    ? const Icon(
                        Icons.check,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  ref
                      .read(languageProvider.notifier)
                      .setLanguage('am');

                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // ABOUT
  // ==========================================================

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.poultryFarmManagement,
          ),
          content: Text(
            l10n.aboutDescription,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // COMING SOON
  // ==========================================================

  void _showComingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.settingAvailableSoon,
        ),
      ),
    );
  }

  // ==========================================================
  // SIGN OUT
  // ==========================================================

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.signOut),
          content: Text(
            l10n.confirmSignOut,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.cancel),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await Supabase.instance.client.auth.signOut();
                } catch (error) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l10n.unableToSignOut}: $error',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.signOut),
            ),
          ],
        );
      },
    );
  }
}