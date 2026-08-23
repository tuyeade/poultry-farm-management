import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:poultry_farm_management/core/services/farm_service.dart';

class DailyProductionPage extends StatefulWidget {
  const DailyProductionPage({super.key});

  @override
  State<DailyProductionPage> createState() => _DailyProductionPageState();
}

class _DailyProductionPageState extends State<DailyProductionPage> {
  final _eggsController = TextEditingController();
  final _brokenController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;
  DateTime _productionDate = DateTime.now();
  String? _selectedBatchId;
  List<Map<String, dynamic>> _batches = [];
  List<Map<String, dynamic>> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _eggsController.dispose();
    _brokenController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final results = await Future.wait([
        Supabase.instance.client
            .from('chicken_batches')
            .select('id, batch_name')
            .eq('farm_id', await _farmId(user.id))
            .order('created_at', ascending: false),
        Supabase.instance.client
            .from('daily_production')
            .select(
              'id, eggs_collected, broken_eggs, production_date, notes, batch_id',
            )
            .eq('farm_id', await _farmId(user.id))
            .order('production_date', ascending: false)
            .limit(10),
      ]);

      if (!mounted) return;
      setState(() {
        _batches = List<Map<String, dynamic>>.from(results[0]);
        _recentRecords = List<Map<String, dynamic>>.from(results[1]);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _message(
        AppLocalizations.of(context)!.unableToLoadProduction(error.toString()),
      );
    }
  }

  Future<void> _saveProduction() async {
    final l10n = AppLocalizations.of(context)!;
    final eggs = int.tryParse(_eggsController.text.trim());
    final broken = int.tryParse(_brokenController.text.trim()) ?? 0;
    if (eggs == null || eggs <= 0 || _selectedBatchId == null) {
      _message(AppLocalizations.of(context)!.enterPositiveEggs);
      return;
    }
    if (broken < 0 || broken > eggs) {
      _message(AppLocalizations.of(context)!.checkBrokenEggs);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final client = Supabase.instance.client;
      final farmId = await FarmService.getCurrentFarmId();
      
      if (farmId == null) {
        throw StateError('No farm found for the current user.');
      }

      await client.from('daily_production').insert({
        'farm_id': farmId,
        'batch_id': _selectedBatchId,
        'production_date': _date(_productionDate),
        'eggs_collected': eggs,
        'broken_eggs': broken,
        'dirty_eggs': 0,
        'eggs_used_home': 0,
        'eggs_incubated': 0,
        'notes': _notesController.text.trim(),
      });

      if (!mounted) return;
      _eggsController.clear();
      _brokenController.text = '0';
      _notesController.clear();
      await _loadData();
      _message(l10n.productionRecordSaved, success: true);
    } catch (error) {
      if (mounted) {
        _message(
          l10n.unableToSaveRecord(error.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _productionDate,
    );
    if (selected != null) setState(() => _productionDate = selected);
  }

  void _message(String text, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppLocalizations.of(context)!.dailyProduction,
          style: AppTextStyles.heading3.copyWith(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _formCard(),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.recentRecords,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_recentRecords.isEmpty)
                      _emptyRecords()
                    else
                      ..._recentRecords.map(_recordCard),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _formCard() => Card(
    elevation: 0,
    color: AppColors.surface,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.recordTodaysProduction,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 18),
          _label(AppLocalizations.of(context)!.date),
          _dateField(),
          const SizedBox(height: 14),
          _label(AppLocalizations.of(context)!.batch),
          DropdownButtonFormField<String>(
            initialValue: _selectedBatchId,
            decoration: _fieldDecoration(),
            hint: Text(
              AppLocalizations.of(context)!.selectBatch,
              style: TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
            items: _batches
                .map(
                  (batch) => DropdownMenuItem<String>(
                    value: batch['id'].toString(),
                    child: Text(
                        batch['batch_name']?.toString() ??
                          AppLocalizations.of(context)!.unnamedBatch,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedBatchId = value),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  AppLocalizations.of(context)!.eggsCollected,
                  _eggsController,
                  Icons.egg_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  AppLocalizations.of(context)!.brokenEggs,
                  _brokenController,
                  Icons.egg_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _label(AppLocalizations.of(context)!.notes),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: _fieldDecoration(
              hint: AppLocalizations.of(context)!.productionNotesHint,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProduction,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                      AppLocalizations.of(context)!.saveProductionRecord,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _dateField() => InkWell(
    onTap: _pickDate,
    borderRadius: BorderRadius.circular(14),
    child: InputDecorator(
      decoration: _fieldDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MM/dd/yyyy').format(_productionDate),
            style: const TextStyle(color: Colors.black),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: Colors.black,
          ),
        ],
      ),
    ),
  );

  Widget _numberField(
    String label,
    TextEditingController controller,
    IconData icon, {
    Color color = AppColors.secondary,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label, icon: icon, color: color),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.black),
        decoration: _fieldDecoration(),
      ),
    ],
  );

  Widget _label(String text, {IconData? icon, Color color = Colors.black}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            if (icon != null) Icon(icon, size: 14, color: color),
            if (icon != null) const SizedBox(width: 3),
            Text(
              text,
              style: AppTextStyles.label.copyWith(
                fontSize: 11,
                letterSpacing: 0.4,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );

  InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black),
    labelStyle: const TextStyle(color: Colors.black),
    floatingLabelStyle: const TextStyle(color: Colors.black),
    filled: true,
    fillColor: const Color(0xFFF4F1EE),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  Widget _recordCard(Map<String, dynamic> record) => Card(
    elevation: 0,
    color: AppColors.surface,
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    child: ListTile(
      leading: const Icon(Icons.egg_outlined, color: AppColors.secondary),
      title: Text(
        '${record['eggs_collected'] ?? 0} ${AppLocalizations.of(context)!.eggs}',
        style: AppTextStyles.titleMedium.copyWith(color: Colors.black),
      ),
      subtitle: Text(
        '${record['production_date'] ?? ''}  |  ${AppLocalizations.of(context)!.brokenCount(record['broken_eggs'] ?? 0)}',
        style: AppTextStyles.bodySmall.copyWith(color: Colors.black),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
    ),
  );

  Widget _emptyRecords() => Card(
    elevation: 0,
    color: AppColors.surface,
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.noProductionRecords,
          style: TextStyle(color: Colors.black),
        ),
      ),
    ),
  );

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<String> _farmId(String userId) async {
    final farm = await Supabase.instance.client
        .from('farms')
        .select('id')
        .eq('owner_id', userId)
        .maybeSingle();
    if (farm == null) throw StateError('No farm is connected to this account.');
    return farm['id'].toString();
  }
}
