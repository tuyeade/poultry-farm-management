import 'package:flutter/material.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/batch_model.dart';
import '../../data/repositories/batch_repositories.dart';

class AddBatchPage extends StatefulWidget {
  final BatchModel? batch;
  const AddBatchPage({super.key, this.batch});

  @override
  State<AddBatchPage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<AddBatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _batchNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _birdCountController = TextEditingController();
  final _ageController = TextEditingController();
  final _mortalityController = TextEditingController(text: '0');
  final BatchRepository _repository = BatchRepository();
  String _status = 'Active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final batch = widget.batch;
    if (batch != null) {
      _batchNameController.text = batch.batchName;
      _breedController.text = batch.breed;
      _birdCountController.text = batch.birdCount.toString();
      _ageController.text = batch.ageWeeks.toString();
      _mortalityController.text = batch.mortalityCount.toString();
      _status = batch.status;
    }
  }

  @override
  void dispose() {
    _batchNameController.dispose();
    _breedController.dispose();
    _birdCountController.dispose();
    _ageController.dispose();
    _mortalityController.dispose();
    super.dispose();
  }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final name = _batchNameController.text.trim();
      final breed = _breedController.text.trim();
      final birds = int.parse(_birdCountController.text);
      final age = int.parse(_ageController.text);
      final mortality = int.parse(_mortalityController.text);
      if (widget.batch == null) {
        await _repository.addBatch(
          batchName: name,
          breed: breed,
          birdCount: birds,
          ageWeeks: age,
          mortalityCount: mortality,
          status: _status,
        );
      } else {
        await _repository.updateBatch(
          widget.batch!.copyWith(
            batchName: name,
            breed: breed,
            birdCount: birds,
            ageWeeks: age,
            mortalityCount: mortality,
            status: _status,
            updatedAt: DateTime.now(),
          ),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.batch == null
                ? 'Batch added successfully'
                : 'Batch updated successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.unableToSaveBatch(error.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(
        widget.batch == null
          ? AppLocalizations.of(context)!.addChickenBatch
          : AppLocalizations.of(context)!.editChickenBatch,
        style: AppTextStyles.heading3.copyWith(color: Colors.black),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 0,
            color: AppColors.surface,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.batch == null
                      ? AppLocalizations.of(context)!.addChickenBatch
                      : AppLocalizations.of(context)!.editChickenBatch,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _label(AppLocalizations.of(context)!.batchName),
                  _textField(
                    _batchNameController,
                    AppLocalizations.of(context)!.batchNameHint,
                    required: true,
                  ),
                  const SizedBox(height: 14),
                  _label(AppLocalizations.of(context)!.breed),
                  _textField(
                    _breedController,
                    AppLocalizations.of(context)!.breedHint,
                    required: true,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          AppLocalizations.of(context)!.birdCount,
                          _birdCountController,
                          positive: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          AppLocalizations.of(context)!.ageWeeks,
                          _ageController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _label(AppLocalizations.of(context)!.mortalityCount),
                  _numberField(
                    AppLocalizations.of(context)!.mortalityCount,
                    _mortalityController,
                  ),
                  const SizedBox(height: 14),
                  _label(AppLocalizations.of(context)!.status),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: _decoration(
                      AppLocalizations.of(context)!.selectStatus,
                    ),
                    style: const TextStyle(color: Colors.black),
                    items: [
                      DropdownMenuItem(
                        value: 'Active',
                        child: Text(
                          AppLocalizations.of(context)!.active,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Inactive',
                        child: Text(
                          AppLocalizations.of(context)!.inactive,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _status = value ?? 'Active'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBatch,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              widget.batch == null
                                  ? AppLocalizations.of(context)!.saveChickenBatch
                                  : AppLocalizations.of(context)!.saveChanges,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      value,
      style: AppTextStyles.label.copyWith(
        color: Colors.black,
        fontSize: 11,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _textField(
    TextEditingController controller,
    String hint, {
    required bool required,
  }) => TextFormField(
    controller: controller,
    style: const TextStyle(color: Colors.black),
    decoration: _decoration(hint),
    validator: (value) =>
        required && (value == null || value.trim().isEmpty)
          ? AppLocalizations.of(context)!.required
          : null,
  );

  Widget _numberField(
    String label,
    TextEditingController controller, {
    bool positive = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.black),
        decoration: _decoration(
          positive
              ? AppLocalizations.of(context)!.totalBirds
              : AppLocalizations.of(context)!.ageLabel,
        ),
        validator: (value) {
          final number = int.tryParse(value?.trim() ?? '');
          if (number == null || (positive ? number <= 0 : number < 0)) {
            return positive
              ? AppLocalizations.of(context)!.enterPositiveCount
              : AppLocalizations.of(context)!.enterValidAge;
          }
          return null;
        },
      ),
    ],
  );

  InputDecoration _decoration(String hint) => InputDecoration(
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
}
