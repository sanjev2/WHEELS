import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/core/services/storage/user_session.dart';
import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';

class AppColors {
  static const bg = Color(0xFFF5F7F7);
  static const surface = Colors.white;

  static const primaryGreen = Color(0xFF16A34A);
  static const secondaryGreen = Color(0xFF10B981);

  static const textPrimary = Color(0xFF0B1220);
  static const textTertiary = Colors.black54;
  static const textSubtle = Colors.black38;

  static Color borderLight = Colors.black.withOpacity(0.06);
  static Color borderSofter = Colors.black.withOpacity(0.08);
  static Color shadowSoft = Colors.black.withOpacity(0.06);
}

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameC;
  late final TextEditingController _contactC;
  late final TextEditingController _addressC;

  bool _saving = false;

  String _readUserIdFromSession(Map<String, dynamic> data) {
    final candidates = ["userId", "authId", "_id", "id"];
    for (final k in candidates) {
      final v = data[k];
      if (v != null && v.toString().trim().isNotEmpty)
        return v.toString().trim();
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    final data = ref.read(userSessionServiceProvider).getUserData();

    _nameC = TextEditingController(text: (data["name"] ?? "").toString());
    _contactC = TextEditingController(text: (data["contact"] ?? "").toString());
    _addressC = TextEditingController(text: (data["address"] ?? "").toString());
  }

  @override
  void dispose() {
    _nameC.dispose();
    _contactC.dispose();
    _addressC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final session = ref.read(userSessionServiceProvider);
    final data = session.getUserData();
    final userId = _readUserIdFromSession(data);

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID missing. Please login again.")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await ref
          .read(authRemoteDatasourceProvider)
          .updateProfile(
            userId: userId,
            name: _nameC.text,
            contact: _contactC.text,
            address: _addressC.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: AppColors.primaryGreen,
          secondary: AppColors.secondaryGreen,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                _SectionCard(
                  title: "Personal Information",
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _CleanTextField(
                          controller: _nameC,
                          label: "Full Name",
                          hint: "Enter your full name",
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            final s = (v ?? "").trim();
                            if (s.length < 2)
                              return "Name must be at least 2 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _CleanTextField(
                          controller: _contactC,
                          label: "Phone",
                          hint: "98XXXXXXXX",
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            final s = (v ?? "").trim();
                            if (s.length < 10)
                              return "Phone must be at least 10 digits";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _CleanTextField(
                          controller: _addressC,
                          label: "Address",
                          hint: "Your current address",
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            final s = (v ?? "").trim();
                            if (s.length < 5)
                              return "Address must be at least 5 characters";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Your profile will be updated securely.",
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CleanTextField extends StatelessWidget {
  const _CleanTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSubtle,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.primaryGreen.withOpacity(0.45),
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
