import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _loading = true;
  List<Map<String, dynamic>> _medicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
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

      final data = await _supabase
          .from('medicines')
          .select()
          .eq('farm_id', farm['id'])
          .order('medicine_name');

      if (!mounted) return;

      setState(() {
        _medicines = List<Map<String, dynamic>>.from(data);
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
            AppLocalizations.of(context)!.unableToLoadMedicines(error.toString()),
          ),
        ),
      );
    }
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

  Future<void> _showMedicineDialog({Map<String, dynamic>? medicine}) async {
    final isEditing = medicine != null;

    final nameController = TextEditingController(
      text: medicine?['medicine_name']?.toString() ?? '',
    );

    final quantityController = TextEditingController(
      text: medicine?['quantity']?.toString() ?? '',
    );

    final costController = TextEditingController(
      text: medicine?['purchase_cost']?.toString() ?? '',
    );

    DateTime? expiryDate;

    if (medicine?['expiry_date'] != null) {
      expiryDate = DateTime.tryParse(medicine!['expiry_date'].toString());
    }

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
                          ? AppLocalizations.of(dialogContext)!.editMedicine
                          : AppLocalizations.of(dialogContext)!.addMedicine,
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(dialogContext)!.medicineName,
                              hintText: AppLocalizations.of(dialogContext)!.medicineHint,
                              prefixIcon: Icon(Icons.medication_outlined),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(dialogContext)!.quantity,
                              hintText: AppLocalizations.of(dialogContext)!.quantityHint,
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: costController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(dialogContext)!.purchaseCost,
                              hintText: AppLocalizations.of(dialogContext)!.costHint,
                              prefixIcon: Icon(Icons.payments_outlined),
                            ),
                          ),

                          const SizedBox(height: 12),

                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today_outlined),
                            title: Text(AppLocalizations.of(dialogContext)!.expiryDate),
                            subtitle: Text(
                              expiryDate == null
                                  ? AppLocalizations.of(dialogContext)!.notSet
                                  : DateFormat.yMMMd().format(expiryDate!),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_calendar_outlined),
                              onPressed: () async {
                                final selected = await showDatePicker(
                                  context: dialogContext,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                  initialDate: expiryDate ?? DateTime.now(),
                                );

                                if (selected != null) {
                                  setDialogState(() {
                                    expiryDate = selected;
                                  });
                                }
                              },
                            ),
                          ),

                          if (expiryDate != null)
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  expiryDate = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: Text(AppLocalizations.of(dialogContext)!.removeExpiryDate),
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
                          final name = nameController.text.trim();

                          final quantity =
                              int.tryParse(quantityController.text.trim()) ?? 0;

                          final cost =
                              double.tryParse(costController.text.trim()) ?? 0;

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(dialogContext)!.pleaseEnterMedicineName,
                                ),
                              ),
                            );
                            return;
                          }

                          if (quantity < 0) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(dialogContext)!.quantityCannotBeNegative,
                                ),
                              ),
                            );
                            return;
                          }

                          if (cost < 0) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(dialogContext)!.purchaseCostCannotBeNegative,
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            final farmId = await _getFarmId();

                            final data = {
                              'farm_id': farmId,
                              'medicine_name': name,
                              'quantity': quantity,
                              'expiry_date': expiryDate == null
                                  ? null
                                  : DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(expiryDate!),
                              'purchase_cost': cost,
                            };

                            if (isEditing) {
                              await _supabase
                                  .from('medicines')
                                  .update(data)
                                  .eq('id', medicine['id']);
                            } else {
                              await _supabase.from('medicines').insert(data);
                            }

                            if (!dialogContext.mounted) return;

                            FocusScope.of(dialogContext).unfocus();
                            Navigator.of(dialogContext).pop(true);
                          } catch (error) {
                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(dialogContext)!.unableToSaveMedicine(error.toString()),
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
      nameController.dispose();
      quantityController.dispose();
      costController.dispose();
    }

    if (saved && mounted) {
      if (mounted) await _loadMedicines();
    }
  }

  Future<void> _deleteMedicine(Map<String, dynamic> medicine) async {
    final name = medicine['medicine_name']?.toString() ?? AppLocalizations.of(context)!.medicine;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(dialogContext)!.deleteMedicine),
          content: Text(
            AppLocalizations.of(dialogContext)!.confirmDeleteNamedMedicine(name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
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
      await _supabase.from('medicines').delete().eq('id', medicine['id']);

      await _loadMedicines();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.unableToDeleteMedicine(error.toString()),
          ),
        ),
      );
    }
  }

  bool _isExpired(dynamic date) {
    if (date == null) return false;

    final expiry = DateTime.tryParse(date.toString());

    if (expiry == null) return false;

    final today = DateTime.now();

    return expiry.isBefore(DateTime(today.year, today.month, today.day));
  }

  bool _expiresSoon(dynamic date) {
    if (date == null) return false;

    final expiry = DateTime.tryParse(date.toString());

    if (expiry == null) return false;

    final today = DateTime.now();
    final difference = expiry.difference(
      DateTime(today.year, today.month, today.day),
    );

    return difference.inDays >= 0 && difference.inDays <= 30;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.medicines,
          style: AppTextStyles.heading3.copyWith(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMedicineDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addMedicine),
      ),

      body: RefreshIndicator(onRefresh: _loadMedicines, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_medicines.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Icon(
            Icons.medication_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              AppLocalizations.of(context)!.noMedicinesRecorded,
              style: AppTextStyles.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(AppLocalizations.of(context)!.addMedicinesDescription),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _summaryCard(),
        const SizedBox(height: 16),

        Text(AppLocalizations.of(context)!.medicineInventory, style: AppTextStyles.titleLarge),

        const SizedBox(height: 10),

        ..._medicines.map(_medicineCard),
      ],
    );
  }

  Widget _summaryCard() {
    final totalItems = _medicines.fold<int>(
      0,
      (sum, medicine) => sum + ((medicine['quantity'] as num?)?.toInt() ?? 0),
    );

    final expired = _medicines
        .where((medicine) => _isExpired(medicine['expiry_date']))
        .length;

    final expiringSoon = _medicines
        .where((medicine) => _expiresSoon(medicine['expiry_date']))
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
              AppLocalizations.of(context)!.medicineOverview,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textLight,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    Icons.medication_outlined,
                    AppLocalizations.of(context)!.types,
                    '${_medicines.length}',
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    Icons.inventory_2_outlined,
                    AppLocalizations.of(context)!.totalUnits,
                    '$totalItems',
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
                    AppLocalizations.of(context)!.expiring,
                    '$expiringSoon',
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    Icons.error_outline,
                    AppLocalizations.of(context)!.expired,
                    '$expired',
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

  Widget _medicineCard(Map<String, dynamic> medicine) {
    final name = medicine['medicine_name']?.toString() ?? AppLocalizations.of(context)!.medicine;

    final quantity = (medicine['quantity'] as num?)?.toInt() ?? 0;

    final cost = (medicine['purchase_cost'] as num?)?.toDouble() ?? 0;

    final expiry = medicine['expiry_date'];

    final expired = _isExpired(expiry);
    final soon = _expiresSoon(expiry);

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
                    Icons.medication_outlined,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 3),
                      Text(
                        AppLocalizations.of(context)!.quantityCount(quantity),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showMedicineDialog(medicine: medicine);
                    } else if (value == 'delete') {
                      _deleteMedicine(medicine);
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
                    Icons.payments_outlined,
                    AppLocalizations.of(context)!.cost,
                    '${cost.toStringAsFixed(2)} ETB',
                  ),
                ),

                Expanded(
                  child: _info(
                    Icons.calendar_today_outlined,
                    'Expiry',
                    expiry == null
                        ? AppLocalizations.of(context)!.notSet
                        : DateFormat.yMMMd().format(
                            DateTime.parse(expiry.toString()),
                          ),
                  ),
                ),
              ],
            ),

            if (expired || soon) ...[
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (expired ? AppColors.error : AppColors.accent)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      expired
                          ? Icons.error_outline
                          : Icons.warning_amber_outlined,
                      size: 18,
                      color: expired ? AppColors.error : AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        expired
                            ? AppLocalizations.of(context)!.medicineExpired
                            : AppLocalizations.of(context)!.medicineExpiresSoon,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: expired ? AppColors.error : AppColors.accent,
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
