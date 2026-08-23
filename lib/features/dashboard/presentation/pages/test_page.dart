import 'package:flutter/material.dart';
import '../../../../app/localization/generated/app_localizations.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/loading_indicator.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.poultryFarmManagement)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              title: 'Total Chickens',
              value: '500',
              icon: Icons.pets,
              iconColor: Colors.brown,
            ),

            const SectionTitle(title: 'Quick Actions'),

            const SizedBox(height: 16),

            const LoadingIndicator(),

            const SizedBox(height: 16),

            AppCard(
              title: 'Eggs Today',
              value: '420',
              icon: Icons.egg_alt,
              iconColor: Colors.orange,
            ),

            const SizedBox(height: 24),

            CustomTextField(
              labelText: l10n.email,
              prefixIcon: Icons.email_outlined,
            ),

            const SizedBox(height: 20),

            CustomButton(text: 'Login', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
