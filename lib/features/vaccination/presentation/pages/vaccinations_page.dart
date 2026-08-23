import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class VaccinationsPage extends StatefulWidget {
  const VaccinationsPage({super.key});

  @override
  State<VaccinationsPage> createState() => _VaccinationsPageState();
}

class _VaccinationsPageState extends State<VaccinationsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _loading = true;

  List<Map<String, dynamic>> _vaccinations = [];
  List<Map<String, dynamic>> _batches = [];
  List<Map<String, dynamic>> _medicines = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<String> _getFarmId() async {
  final user = _supabase.auth.currentUser;

  if (user == null) {
    throw Exception('You must be signed in.');
  }

  final farm = await _supabase
      .from('farms')
      .select('id')
      .eq('owner_id', user.id)
      .maybeSingle();

  if (farm == null) {
    throw Exception('No farm is connected to this account.');
  }

  return farm['id'].toString();
}

  Future<void> _waitForDialogToClose(ModalRoute<dynamic> route) {
    final animation = route.animation;

    if (animation == null || animation.status == AnimationStatus.dismissed) {
      return Future.value();
    }

    final completer = Completer<void>();

    void handleStatus(AnimationStatus status) {
      if (status != AnimationStatus.dismissed) return;

      animation.removeStatusListener(handleStatus);
      completer.complete();
    }

    animation.addStatusListener(handleStatus);

    if (animation.status == AnimationStatus.dismissed) {
      animation.removeStatusListener(handleStatus);
      completer.complete();
    }

    return completer.future;
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      final farmId = await _getFarmId();

      // Load medicines belonging to this farm.
      final medicines = await _supabase
          .from('medicines')
          .select('id, medicine_name, quantity, expiry_date')
          .eq('farm_id', farmId)
          .order('medicine_name');

      // Load chicken batches belonging to this farm.
      //
      // If your chicken_batches table uses a different column
      // for the farm relationship, change this query accordingly.
      final batches = await _supabase
          .from('chicken_batches')
          .select()
          .eq('farm_id', farmId)
          .order('created_at', ascending: false);

      // Load vaccinations through the batch relationship.
      final vaccinations = batches.isEmpty
          ? <Map<String, dynamic>>[]
          : await _supabase
                .from('vaccinations')
                .select(
                  'id, batch_id, medicine_id, vaccination_date, '
                  'next_due_date, notes',
                )
                .inFilter(
                  'batch_id',
                  batches.map((batch) => batch['id']).toList(),
                )
                .order('vaccination_date', ascending: false);

      if (!mounted) return;

      setState(() {
        _medicines = List<Map<String, dynamic>>.from(medicines);
        _batches = List<Map<String, dynamic>>.from(batches);
        _vaccinations = List<Map<String, dynamic>>.from(vaccinations);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.unableToLoadVaccinations(error.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _showVaccinationDialog({
    Map<String, dynamic>? vaccination,
  }) async {
    final isEditing = vaccination != null;

    String? selectedBatchId = vaccination?['batch_id']?.toString();

    String? selectedMedicineId = vaccination?['medicine_id']?.toString();

    DateTime vaccinationDate = vaccination?['vaccination_date'] != null
        ? DateTime.tryParse(vaccination!['vaccination_date'].toString()) ??
              DateTime.now()
        : DateTime.now();

    DateTime? nextDueDate;

    if (vaccination?['next_due_date'] != null) {
      nextDueDate = DateTime.tryParse(vaccination!['next_due_date'].toString());
    }

    final notesController = TextEditingController(
      text: vaccination?['notes']?.toString() ?? '',
    );

    bool saved = false;
    late ModalRoute<dynamic> dialogRoute;
    try {
      saved =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              dialogRoute = ModalRoute.of(dialogContext)!;

              return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing
                  ? AppLocalizations.of(dialogContext)!.editVaccination
                  : AppLocalizations.of(dialogContext)!.recordVaccination,
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BATCH
                    DropdownButtonFormField<String>(
                      initialValue: _containsId(_batches, selectedBatchId)
                          ? selectedBatchId
                          : null,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(dialogContext)!.chickenBatch,
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      items: _batches.map((batch) {
                        final id = batch['id'].toString();

                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(
                            _batchName(batch),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedBatchId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // MEDICINE
                    DropdownButtonFormField<String>(
                      initialValue: _containsId(_medicines, selectedMedicineId)
                          ? selectedMedicineId
                          : null,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(dialogContext)!.medicineVaccine,
                        prefixIcon: Icon(Icons.medication_outlined),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(AppLocalizations.of(dialogContext)!.noMedicineSelected),
                        ),
                        ..._medicines.map((medicine) {
                          final id = medicine['id'].toString();

                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(
                              medicine['medicine_name']?.toString() ??
                                  AppLocalizations.of(dialogContext)!.medicine,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMedicineId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // VACCINATION DATE
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(AppLocalizations.of(dialogContext)!.vaccinationDate),
                      subtitle: Text(
                        DateFormat.yMMMd().format(vaccinationDate),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined),
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: dialogContext,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDate: vaccinationDate,
                          );

                          if (selected != null) {
                            setDialogState(() {
                              vaccinationDate = selected;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 4),

                    // NEXT DUE DATE
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_available_outlined),
                      title: Text(AppLocalizations.of(dialogContext)!.nextDueDate),
                      subtitle: Text(
                        nextDueDate == null
                            ? AppLocalizations.of(dialogContext)!.notSet
                            : DateFormat.yMMMd().format(nextDueDate!),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined),
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: dialogContext,
                            firstDate: vaccinationDate,
                            lastDate: DateTime(2100),
                            initialDate: nextDueDate ?? vaccinationDate,
                          );

                          if (selected != null) {
                            setDialogState(() {
                              nextDueDate = selected;
                            });
                          }
                        },
                      ),
                    ),

                    if (nextDueDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              nextDueDate = null;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: Text(AppLocalizations.of(dialogContext)!.removeDueDate),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // NOTES
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(dialogContext)!.notes,
                        hintText: AppLocalizations.of(dialogContext)!.addVaccinationNotes,
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(AppLocalizations.of(dialogContext)!.cancel),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (selectedBatchId == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(dialogContext)!.pleaseSelectChickenBatch,
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      final data = {
  'batch_id': selectedBatchId,
  'medicine_id': selectedMedicineId,
  'vaccination_date': DateFormat(
    'yyyy-MM-dd',
  ).format(vaccinationDate),
  'next_due_date': nextDueDate == null
      ? null
      : DateFormat('yyyy-MM-dd').format(nextDueDate!),
  'notes': notesController.text.trim().isEmpty
      ? null
      : notesController.text.trim(),
};

                      if (isEditing) {
                        await _supabase
                            .from('vaccinations')
                            .update(data)
                            .eq('id', vaccination['id']);
                      } else {
                        await _supabase.from('vaccinations').insert(data);
                      }

                      if (!dialogContext.mounted) {
                        return;
                      }

                      FocusScope.of(dialogContext).unfocus();
                      Navigator.of(dialogContext).pop(true);

                    } catch (error) {
                      if (!dialogContext.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(dialogContext)!.unableToSaveRecord(error.toString()),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isEditing
                        ? AppLocalizations.of(dialogContext)!.update
                        : AppLocalizations.of(dialogContext)!.save,
                  ),
                ),
              ],
            );
          },
              );
            },
          ) ??
          false;
    } finally {
      if (saved) {
        await _waitForDialogToClose(dialogRoute);
        await WidgetsBinding.instance.endOfFrame;
      }

      notesController.dispose();
    }

    if (saved && mounted) {
      await _loadData();
    }
  }

  Future<void> _deleteVaccination(Map<String, dynamic> vaccination) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(dialogContext)!.deleteVaccination),
          content: Text(AppLocalizations.of(dialogContext)!.confirmDeleteVaccination),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(dialogContext)!.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _supabase.from('vaccinations').delete().eq('id', vaccination['id']);

      await _loadData();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.unableToSaveRecord(error.toString()),
          ),
        ),
      );
    }
  }

  bool _containsId(List<Map<String, dynamic>> items, String? id) {
    if (id == null) return false;

    return items.any((item) => item['id'].toString() == id);
  }

  String _batchName(Map<String, dynamic> batch) {
    // Try common names used in chicken_batches.
    if (batch['batch_name'] != null) {
      return batch['batch_name'].toString();
    }

    if (batch['name'] != null) {
      return batch['name'].toString();
    }

    if (batch['batch_number'] != null) {
      return '${AppLocalizations.of(context)!.batch} ${batch['batch_number']}';
    }

    return '${AppLocalizations.of(context)!.batch} ${batch['id'].toString().substring(0, 8)}';
  }

  Map<String, dynamic>? _findBatch(String? id) {
    if (id == null) return null;

    for (final batch in _batches) {
      if (batch['id'].toString() == id) {
        return batch;
      }
    }

    return null;
  }

  String _medicineName(String? id) {
    if (id == null) {
      return AppLocalizations.of(context)!.noMedicine;
    }

    for (final medicine in _medicines) {
      if (medicine['id'].toString() == id) {
        return medicine['medicine_name']?.toString() ?? AppLocalizations.of(context)!.medicine;
      }
    }

    return AppLocalizations.of(context)!.medicine;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  bool _isDueSoon(dynamic value) {
    final date = _parseDate(value);

    if (date == null) return false;

    final today = DateTime.now();

    final difference = date.difference(
      DateTime(today.year, today.month, today.day),
    );

    return difference.inDays >= 0 && difference.inDays <= 30;
  }

  bool _isOverdue(dynamic value) {
    final date = _parseDate(value);

    if (date == null) return false;

    final today = DateTime.now();

    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.vaccinations,
          style: AppTextStyles.heading3.copyWith(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVaccinationDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.recordVaccination),
      ),

      body: RefreshIndicator(onRefresh: _loadData, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vaccinations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),

          Icon(
            Icons.vaccines_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              AppLocalizations.of(context)!.noVaccinationsRecorded,
              style: AppTextStyles.titleMedium,
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(AppLocalizations.of(context)!.vaccinationsDescription),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _summaryCard(),

        const SizedBox(height: 18),

        Text(AppLocalizations.of(context)!.vaccinationRecords, style: AppTextStyles.titleLarge),

        const SizedBox(height: 10),

        ..._vaccinations.map(_vaccinationCard),
      ],
    );
  }

  Widget _summaryCard() {
    final upcoming = _vaccinations
        .where((item) => _isDueSoon(item['next_due_date']))
        .length;

    final overdue = _vaccinations
        .where((item) => _isOverdue(item['next_due_date']))
        .length;

    return Card(
      elevation: 0,
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.vaccinationOverview,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textLight,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    Icons.vaccines_outlined,
                    AppLocalizations.of(context)!.records,
                    '${_vaccinations.length}',
                  ),
                ),

                Expanded(
                  child: _summaryItem(
                    Icons.event_available_outlined,
                    AppLocalizations.of(context)!.dueSoon,
                    '$upcoming',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    Icons.warning_amber_outlined,
                    AppLocalizations.of(context)!.overdue,
                    '$overdue',
                  ),
                ),

                Expanded(
                  child: _summaryItem(
                    Icons.groups_outlined,
                    AppLocalizations.of(context)!.batches,
                    '${_batches.length}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textLight.withValues(alpha: 0.85),
          size: 22,
        ),

        const SizedBox(width: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textLight,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _vaccinationCard(Map<String, dynamic> vaccination) {
    final batch = _findBatch(vaccination['batch_id']?.toString());

    final batchName = batch == null
      ? AppLocalizations.of(context)!.unknownBatch
      : _batchName(batch);

    final medicineName = _medicineName(vaccination['medicine_id']?.toString());

    final vaccinationDate = _parseDate(vaccination['vaccination_date']);

    final nextDueDate = _parseDate(vaccination['next_due_date']);

    final overdue = _isOverdue(vaccination['next_due_date']);

    final dueSoon = _isDueSoon(vaccination['next_due_date']);

    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.vaccines_outlined,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medicineName, style: AppTextStyles.titleMedium),

                      const SizedBox(height: 3),

                      Text(batchName, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showVaccinationDialog(vaccination: vaccination);
                    } else if (value == 'delete') {
                      _deleteVaccination(vaccination);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text(AppLocalizations.of(context)!.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 10),
                          Text(AppLocalizations.of(context)!.delete),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(height: 1),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _info(
                    Icons.calendar_today_outlined,
                    AppLocalizations.of(context)!.vaccinated,
                    vaccinationDate == null
                        ? AppLocalizations.of(context)!.notSet
                        : DateFormat.yMMMd().format(vaccinationDate),
                  ),
                ),

                Expanded(
                  child: _info(
                    Icons.event_available_outlined,
                    AppLocalizations.of(context)!.nextDueDate,
                    nextDueDate == null
                        ? AppLocalizations.of(context)!.notSet
                        : DateFormat.yMMMd().format(nextDueDate),
                  ),
                ),
              ],
            ),

            if (vaccination['notes'] != null &&
                vaccination['notes'].toString().trim().isNotEmpty) ...[
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  vaccination['notes'].toString(),
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],

            if (overdue || dueSoon) ...[
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (overdue ? AppColors.error : AppColors.accent)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      overdue
                          ? Icons.error_outline
                          : Icons.warning_amber_outlined,
                      size: 18,
                      color: overdue ? AppColors.error : AppColors.accent,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        overdue
                            ? AppLocalizations.of(context)!.vaccinationOverdue
                            : AppLocalizations.of(context)!.vaccinationDueSoon,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: overdue ? AppColors.error : AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),

              const SizedBox(height: 2),

              Text(
                value,
                style: AppTextStyles.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
