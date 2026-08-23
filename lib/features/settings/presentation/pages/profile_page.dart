import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // LOAD PROFILE
  // ----------------------------------------------------------

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('You must be signed in.');
      }

      _email = user.email ?? '';

      final profile = await _supabase
          .from('users')
          .select('full_name, phone')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        _nameController.text =
            profile['full_name']?.toString() ?? '';

        _phoneController.text =
            profile['phone']?.toString() ?? '';
      }

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
          content: Text(AppLocalizations.of(context)!.unableToLoadProfile(error.toString())),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // SAVE PROFILE
  // ----------------------------------------------------------

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterYourFullName),
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
          .from('users')
          .update({
            'full_name': name,
            'phone': phone.isEmpty ? null : phone,
          })
          .eq('id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
        ),
      );

      setState(() {
        _saving = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unableToUpdateProfile(error.toString())),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profile,
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
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                24,
                16,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // PROFILE HEADER
                  // ------------------------------------------------

                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _nameController.text.isEmpty
                              ? AppLocalizations.of(context)!.yourProfile
                              : _nameController.text,
                          style: AppTextStyles.titleLarge,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _email,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // PERSONAL INFORMATION
                  // ------------------------------------------------

                  Text(
                    AppLocalizations.of(context)!.personalInformation,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _inputField(
                    controller: _nameController,
                    label: AppLocalizations.of(context)!.fullName,
                    hint: AppLocalizations.of(context)!.enterYourFullName,
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 14),

                  // EMAIL
                  TextField(
                    enabled: false,
                    controller: TextEditingController(
                      text: _email,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        size: 19,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withValues(
                        alpha: 0.08,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _inputField(
                    controller: _phoneController,
                    label: AppLocalizations.of(context)!.phoneNumber,
                    hint: AppLocalizations.of(context)!.enterYourPhoneNumber,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------
                  // SAVE BUTTON
                  // ------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              AppLocalizations.of(context)!.saveChanges,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ----------------------------------------------------------
  // INPUT FIELD
  // ----------------------------------------------------------

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}