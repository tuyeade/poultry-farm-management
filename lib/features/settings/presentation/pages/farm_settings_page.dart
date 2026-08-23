import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class FarmSettingsPage extends StatefulWidget {
  const FarmSettingsPage({super.key});

  @override
  State<FarmSettingsPage> createState() => _FarmSettingsPageState();
}

class _FarmSettingsPageState extends State<FarmSettingsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();

  final _farmNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String? _farmId;

  @override
  void initState() {
    super.initState();
    _loadFarm();
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOAD FARM
  // ==========================================================

  Future<void> _loadFarm() async {
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
          .select(
            'id, farm_name, owner_name, phone, address',
          )
          .eq('owner_id', user.id)
          .maybeSingle();

      if (farm == null) {
        throw Exception(
          'No farm is connected to this account.',
        );
      }

      _farmId = farm['id'].toString();

      _farmNameController.text =
          farm['farm_name']?.toString() ?? '';

      _ownerNameController.text =
          farm['owner_name']?.toString() ?? '';

      _phoneController.text =
          farm['phone']?.toString() ?? '';

      _addressController.text =
          farm['address']?.toString() ?? '';

      if (!mounted) return;

      setState(() {
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
            AppLocalizations.of(context)!.unableToLoadFarmInformation(error.toString()),
          ),
        ),
      );
    }
  }

  // ==========================================================
  // SAVE FARM
  // ==========================================================

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_farmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.farmInformationUnavailable),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('You must be signed in.');
      }

      await _supabase
          .from('farms')
          .update({
            'farm_name': _farmNameController.text.trim(),
            'owner_name': _ownerNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _farmId!)
          .eq('owner_id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.farmInformationUpdatedSuccessfully),
        ),
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.unableToSaveFarm(error.message),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.unableToSaveFarm(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.farmSettings,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadFarm,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  40,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // FARM ICON
                      Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.agriculture_outlined,
                            size: 46,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.farmInformation,
                          style: AppTextStyles.heading3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          'Manage your farm information and contact details.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Farm Details',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // FARM NAME
                      TextFormField(
                        controller: _farmNameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Farm Name',
                          hintText: 'Enter farm name',
                          prefixIcon: Icon(
                            Icons.agriculture_outlined,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter the farm name.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // OWNER NAME
                      TextFormField(
                        controller: _ownerNameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Owner Name',
                          hintText: 'Enter owner name',
                          prefixIcon: Icon(
                            Icons.person_outline,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter the owner name.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // PHONE
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          hintText: 'Enter phone number',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ADDRESS
                      TextFormField(
                        controller: _addressController,
                        textCapitalization:
                            TextCapitalization.sentences,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter farm address',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              _saving ? null : _saveFarm,
                          icon: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.save_outlined,
                                ),
                          label: Text(
                            _saving
                                ? 'Saving...'
                                : 'Save Changes',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary,
                            foregroundColor:
                                AppColors.textLight,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}