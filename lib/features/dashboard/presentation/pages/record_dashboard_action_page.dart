import 'package:flutter/material.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/repositories/dashboard_action_repository.dart';

enum DashboardAction { production, sale, feed, expense }

class RecordDashboardActionPage extends StatefulWidget {
  const RecordDashboardActionPage({super.key, required this.action});

  final DashboardAction action;

  @override
  State<RecordDashboardActionPage> createState() =>
      _RecordDashboardActionPageState();
}

class _RecordDashboardActionPageState extends State<RecordDashboardActionPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstController = TextEditingController();
  final _secondController = TextEditingController();
  final _thirdController = TextEditingController();
  final _repository = DashboardActionRepository();
  bool _isSaving = false;

  bool get _isProduction => widget.action == DashboardAction.production;
  bool get _isSale => widget.action == DashboardAction.sale;
  bool get _isFeed => widget.action == DashboardAction.feed;

  String get _title {
    final l10n = AppLocalizations.of(context)!;
    if (_isProduction) return l10n.recordProduction;
    if (_isSale) return l10n.recordSale;
    if (_isFeed) return l10n.addFeed;
    return l10n.addExpense;
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      if (_isProduction) {
        final quantity = int.parse(_firstController.text.trim());
        final broken = int.tryParse(_secondController.text.trim()) ?? 0;
        if (broken > quantity) {
          throw Exception(AppLocalizations.of(context)!.checkBrokenEggs);
        }
        await _repository.recordProduction(
          quantity: quantity,
          brokenQuantity: broken,
          notes: _thirdController.text,
        );
      } else if (_isSale) {
        await _repository.recordSale(
          quantity: double.parse(_firstController.text.trim()),
          unitPrice: double.parse(_secondController.text.trim()),
          notes: _thirdController.text,
        );
      } else if (_isFeed) {
        await _repository.addFeed(
          feedType: _firstController.text,
          quantity: double.parse(_secondController.text.trim()),
          unitCost: double.parse(_thirdController.text.trim()),
        );
      } else {
        await _repository.recordExpense(
          category: _firstController.text,
          amount: double.parse(_secondController.text.trim()),
          description: _thirdController.text,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _label(int index) {
    final l10n = AppLocalizations.of(context)!;
    if (_isProduction) return [l10n.eggsCollected, l10n.brokenEggs, l10n.notes][index];
    if (_isSale) return [l10n.quantity, 'Unit price (ETB)', l10n.notes][index];
    if (_isFeed) {
      return [l10n.feedName, 'Quantity (kg)', 'Unit cost (ETB)'][index];
    }
    return [l10n.category, l10n.amountEur, l10n.description][index];
  }

  String? _validate(String? value, int index) {
    if (index == 2 && !_isFeed) return null;
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.required;
    }
    if (index > 0 || (_isProduction && index == 0)) {
      final number = double.tryParse(value.trim());
      if (number == null ||
          number <= 0 ||
          (index == 1 && _isProduction && number < 0)) {
        return AppLocalizations.of(context)!.enterPositiveCount;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (var index = 0; index < 3; index++) ...[
                TextFormField(
                  controller: [
                    _firstController,
                    _secondController,
                    _thirdController,
                  ][index],
                  keyboardType:
                      index == 0 && (_isFeed || !_isProduction && !_isSale)
                      ? TextInputType.text
                      : (index == 2 && !_isFeed
                            ? TextInputType.multiline
                            : TextInputType.number),
                  maxLines: index == 2 && !_isFeed ? 3 : 1,
                  decoration: InputDecoration(labelText: _label(index)),
                  validator: (value) => _validate(value, index),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
