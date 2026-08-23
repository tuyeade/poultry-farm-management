import 'package:flutter/material.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../data/model/batch_model.dart';
import '../../data/repositories/batch_repositories.dart';
import 'add_batch_page.dart';

class BatchListPage extends StatefulWidget {
  const BatchListPage({super.key});

  @override
  State<BatchListPage> createState() => _BatchListPageState();
}

class _BatchListPageState extends State<BatchListPage> {
  final BatchRepository _repository = BatchRepository();

  late Future<List<BatchModel>> _batchesFuture;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  void _loadBatches() {
    _batchesFuture = _repository.getBatches();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadBatches();
    });
  }

  Future<void> _deleteBatch(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteBatch),
          content: Text(l10n.confirmDeleteBatch),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _repository.deleteBatch(id);

    if (mounted) {
      await _refresh();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;

      case 'inactive':
        return Colors.red;

      default:
        return Colors.orange;
    }
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
          AppLocalizations.of(context)!.chickenBatches,
          style: AppTextStyles.heading3.copyWith(color: Colors.black),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBatchPage()),
          );

          if (added == true) {
            _refresh();
          }
        },
      ),

      body: FutureBuilder<List<BatchModel>>(
        future: _batchesFuture,
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
                    Text(AppLocalizations.of(context)!.unableToLoadChickenBatches),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final batches = snapshot.data ?? [];

          if (batches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 70, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.noChickenBatches,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.tapToCreateBatch),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index];

                return Card(
                  elevation: 0,
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.pets, color: Colors.white),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    batch.batchName,
                                    style: AppTextStyles.titleLarge,
                                  ),

                                  Text(
                                    batch.breed,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  batch.status,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                batch.status,
                                style: TextStyle(
                                  color: _statusColor(batch.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.birdsCount(
                                batch.birdCount,
                              ),
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              AppLocalizations.of(context)!.ageInWeeks(
                                batch.ageWeeks,
                              ),
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              AppLocalizations.of(context)!.mortalityCountValue(
                                batch.mortalityCount,
                              ),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddBatchPage(batch: batch),
                                    ),
                                  );

                                  if (updated == true) {
                                    _refresh();
                                  }
                                },
                                icon: const Icon(Icons.edit),
                                label: Text(AppLocalizations.of(context)!.edit),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  _deleteBatch(batch.id);
                                },
                                icon: const Icon(Icons.delete),
                                label: Text(AppLocalizations.of(context)!.delete),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
