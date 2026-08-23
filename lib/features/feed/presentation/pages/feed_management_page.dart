import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/localization/generated/app_localizations.dart';

class FeedManagementPage extends StatefulWidget {
  const FeedManagementPage({super.key});

  @override
  State<FeedManagementPage> createState() => _FeedManagementPageState();
}

class _FeedManagementPageState extends State<FeedManagementPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> feeds = [];

  @override
  void initState() {
    super.initState();
    loadFeeds();
  }

  Future<void> loadFeeds() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final response = await supabase
          .from('feed_inventory')
          .select()
          .eq('farm_id', await _farmId(user.id))
          .order('purchase_date', ascending: false);

      if (!mounted) return;

      setState(() {
        feeds = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Feed error: $e');

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.unableToLoadFeed}: $e')));
    }
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

  Future<void> showAddFeedDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    final costController = TextEditingController();

    bool saved = false;
    late ModalRoute<dynamic> dialogRoute;
    try {
      saved =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              dialogRoute = ModalRoute.of(dialogContext)!;
              bool saving = false;

              return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.addFeedTitle),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: l10n.feedName),
                    ),

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.quantity),
                    ),

                    TextField(
                      controller: unitController,
                      decoration: InputDecoration(labelText: l10n.unit),
                    ),

                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.cost),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),

                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final quantity = double.tryParse(
                            quantityController.text.trim(),
                          );

                          if (nameController.text.trim().isEmpty ||
                              quantity == null ||
                              quantity <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.enterValidFeed),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            final supabase = Supabase.instance.client;

                            final user = supabase.auth.currentUser;

                            if (user == null) {
                              throw Exception('You are not logged in.');
                            }

                            await supabase.from('feed_inventory').insert({
                              'farm_id': await _farmId(user.id),
                              'feed_name': nameController.text.trim(),
                              'quantity': quantity,
                              'unit': unitController.text.trim(),
                              'cost': double.tryParse(
                                costController.text.trim(),
                              ),
                            });

                            if (!dialogContext.mounted) return;

                            FocusScope.of(dialogContext).unfocus();
                            Navigator.of(dialogContext).pop(true);
                          } catch (e) {
                            setDialogState(() {
                              saving = false;
                            });

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${l10n.unableToAddFeed}: $e')),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
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
      unitController.dispose();
      costController.dispose();
    }

    if (saved && mounted) {
      await loadFeeds();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.feedAddedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double totalQuantity = 0;

    for (final feed in feeds) {
      totalQuantity += (feed['quantity'] as num?)?.toDouble() ?? 0;
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.feedManagement,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadFeeds,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: showAddFeedDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadFeeds,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.grass, color: Colors.white, size: 42),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.totalFeedStock,
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${totalQuantity.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    l10n.feedInventory,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (feeds.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          l10n.noFeedRecords,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  ...feeds.map(
                    (feed) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(Icons.grass, color: Colors.green),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feed['feed_name'] ?? 'Feed',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  '${feed['quantity'] ?? 0} ${feed['unit'] ?? 'kg'}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

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
