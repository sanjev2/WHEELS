import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheels_flutter/core/services/biometric/biometric_providers.dart';
import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:wheels_flutter/features/trip/logic/trip_provider.dart';
import 'package:wheels_flutter/features/trip/logic/trip_sync.dart';

class AppColors {
  static const bg = Color(0xFFF5F7F7);
  static const surface = Colors.white;

  static const primaryGreen = Color(0xFF16A34A);
  static const secondaryGreen = Color(0xFF10B981);

  static const textPrimary = Color(0xFF0B1220);
  static const textTertiary = Colors.black54;

  static Color borderLight = Colors.black.withOpacity(0.06);
  static Color borderSofter = Colors.black.withOpacity(0.08);
  static Color shadowSoft = Colors.black.withOpacity(0.06);
}

class SettingsPagePro extends ConsumerStatefulWidget {
  const SettingsPagePro({super.key});

  @override
  ConsumerState<SettingsPagePro> createState() => _SettingsPageProState();
}

class _SettingsPageProState extends ConsumerState<SettingsPagePro> {
  bool _bioBusy = false;
  bool _syncBusy = false;
  bool _credBusy = false;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _friendlyError(Object e) {
    var msg = e.toString();

    msg = msg.replaceFirst("Exception: ", "");
    msg = msg.replaceFirst("DioException [", "");
    msg = msg.replaceAll("]", "");

    if (msg.contains("401") || msg.toLowerCase().contains("unauthorized")) {
      return "Session expired. Please login again.";
    }
    if (msg.toLowerCase().contains("socketexception") ||
        msg.toLowerCase().contains("connection")) {
      return "No internet connection. Please try again.";
    }
    if (msg.toLowerCase().contains("timeout")) {
      return "Request timed out. Please try again.";
    }

    if (msg.length > 140) msg = msg.substring(0, 140);
    return msg.trim().isEmpty ? "Something went wrong." : msg.trim();
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (_bioBusy) return;
    setState(() => _bioBusy = true);

    final notifier = ref.read(biometricEnabledProvider.notifier);

    try {
      if (enable) {
        final ok = await notifier.enableWithAuth();

        if (!ok) {
          _snack(
            "Biometric not enabled. Device may not support it, no biometrics are enrolled, or authentication was cancelled.",
          );
          return;
        }

        _snack(
          "Biometric enabled. Your next normal login will be saved automatically.",
        );
      } else {
        await notifier.disable();
        _snack("Biometric unlock disabled.");
      }
    } catch (e) {
      _snack(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _bioBusy = false);
    }
  }

  Future<void> _clearBiometricCredentials() async {
    if (_credBusy) return;
    setState(() => _credBusy = true);

    try {
      final credController = ref.read(
        biometricCredentialControllerProvider.notifier,
      );
      await credController.clear();
      await credController.refresh();
      _snack("Saved credentials removed.");
    } catch (e) {
      _snack(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _credBusy = false);
    }
  }

  Future<void> _syncTrips() async {
    if (_syncBusy) return;
    setState(() => _syncBusy = true);

    try {
      final before = await ref.read(tripStatsProvider.future);
      final pendingBefore = before.unsyncedCount;

      await ref.read(tripSyncControllerProvider.notifier).syncNow();

      ref.invalidate(tripStatsProvider);
      ref.invalidate(tripHistoryProvider);

      final after = await ref.read(tripStatsProvider.future);
      final pendingAfter = after.unsyncedCount;

      if (pendingBefore == 0) {
        _snack("No completed trips waiting to sync.");
      } else if (pendingAfter == 0) {
        _snack("Trips synced successfully.");
      } else {
        _snack("Some trips may still be pending sync.");
      }
    } catch (e) {
      _snack(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _syncBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(tripStatsProvider);

    final syncState = ref.watch(tripSyncControllerProvider);
    final syncLoading = syncState.isLoading || _syncBusy;

    final bioEnabled = ref.watch(biometricEnabledProvider);
    final bioLoading = _bioBusy;

    final hasCreds = ref.watch(biometricCredentialControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          _SectionCard(
            title: "Security",
            child: Column(
              children: [
                _SwitchTile(
                  icon: Icons.fingerprint_rounded,
                  title: "Face/Fingerprint unlock",
                  subtitle: bioLoading
                      ? "Please wait..."
                      : "Current login credentials will be saved automatically",
                  value: bioEnabled,
                  enabled: !bioLoading,
                  onChanged: (v) => _toggleBiometric(v),
                ),
                const SizedBox(height: 8),
                _ActionTile(
                  icon: Icons.delete_outline_rounded,
                  title: "Remove saved credentials",
                  subtitle: hasCreds
                      ? "Delete saved email and password"
                      : "No saved credentials",
                  enabled: hasCreds && !_credBusy,
                  trailing: _credBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: _clearBiometricCredentials,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: "Trip Summary",
            child: Column(
              children: [
                statsAsync.when(
                  data: (stats) {
                    return Column(
                      children: [
                        _StatRow(
                          icon: Icons.route_rounded,
                          title: "Total distance",
                          value: "${stats.totalKm.toStringAsFixed(2)} km",
                        ),
                        const SizedBox(height: 10),
                        _StatRow(
                          icon: Icons.calendar_month_rounded,
                          title: "This month",
                          value: "${stats.monthKm.toStringAsFixed(2)} km",
                        ),
                        const SizedBox(height: 10),
                        _StatRow(
                          icon: Icons.confirmation_number_rounded,
                          title: "Trips",
                          value: "${stats.tripsCount}",
                        ),
                        const SizedBox(height: 10),
                        _StatRow(
                          icon: Icons.cloud_upload_rounded,
                          title: "Pending sync",
                          value: "${stats.unsyncedCount}",
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.borderSofter,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  ref.invalidate(tripStatsProvider);
                                  ref.invalidate(tripHistoryProvider);
                                },
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  "Refresh",
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: syncLoading ? null : _syncTrips,
                                icon: syncLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.cloud_upload_rounded,
                                        size: 18,
                                      ),
                                label: Text(
                                  syncLoading ? "Syncing..." : "Sync",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Couldn’t load trip summary.",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _friendlyError(e),
                        style: const TextStyle(color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            ref.invalidate(tripStatsProvider);
                            ref.invalidate(tripHistoryProvider);
                          },
                          child: const Text("Retry"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _SectionCard(
            title: "Account",
            child: Column(
              children: [
                _NavTile(
                  icon: Icons.lock_outline,
                  title: "Change Password",
                  subtitle: "Update your account password",
                  page: ChangePasswordPagePro(),
                ),
              ],
            ),
          ),
        ],
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

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? () => onChanged(!value) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.18),
                  ),
                ),
                child: Icon(icon, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeColor: AppColors.primaryGreen,
                onChanged: enabled ? onChanged : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.18),
                  ),
                ),
                child: Icon(icon, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.18)),
          ),
          child: Icon(icon, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.18),
                ),
              ),
              child: Icon(icon, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.black.withOpacity(0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPagePro extends ConsumerStatefulWidget {
  const ChangePasswordPagePro({super.key});

  @override
  ConsumerState<ChangePasswordPagePro> createState() =>
      _ChangePasswordPageProState();
}

class _ChangePasswordPageProState extends ConsumerState<ChangePasswordPagePro> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  bool _saving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    final current = _currentCtrl.text.trim();
    final next = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty) return "Current password is required";
    if (next.length < 6) return "New password must be at least 6 characters";
    if (confirm.isEmpty) return "Confirm your new password";
    if (next != confirm) return "Passwords do not match";
    if (current == next) return "New password must be different from current";
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(authRemoteDatasourceProvider)
          .changePassword(
            currentPassword: _currentCtrl.text.trim(),
            newPassword: _newCtrl.text.trim(),
          );

      if (!mounted) return;

      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully.")),
      );

      Navigator.maybePop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          Container(
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Update your password",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Enter your current password to set a new one.",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 14),
                _PasswordField(
                  label: "Current Password",
                  controller: _currentCtrl,
                  obscure: !_showCurrent,
                  onToggle: () => setState(() => _showCurrent = !_showCurrent),
                ),
                const SizedBox(height: 10),
                _PasswordField(
                  label: "New Password",
                  controller: _newCtrl,
                  obscure: !_showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                ),
                const SizedBox(height: 10),
                _PasswordField(
                  label: "Confirm New Password",
                  controller: _confirmCtrl,
                  obscure: !_showConfirm,
                  onToggle: () => setState(() => _showConfirm = !_showConfirm),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.borderSofter),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _saving
                            ? null
                            : () {
                                _currentCtrl.clear();
                                _newCtrl.clear();
                                _confirmCtrl.clear();
                                setState(() {
                                  _showCurrent = false;
                                  _showNew = false;
                                  _showConfirm = false;
                                });
                              },
                        child: const Text(
                          "Clear",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Update Password",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.lock_outline, color: Colors.black.withOpacity(0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: "••••••••",
                  ),
                ),
              ),
              IconButton(
                tooltip: obscure ? "Show" : "Hide",
                onPressed: onToggle,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
