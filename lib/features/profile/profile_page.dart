import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wheels_flutter/features/car/presentation/pages/my_cars_page.dart';
import 'package:wheels_flutter/core/api/api_endpoints.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';
import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:wheels_flutter/features/auth/presentation/pages/login_pages.dart';
import 'package:wheels_flutter/features/profile/presentation/edit_profile_page.dart';
import 'package:wheels_flutter/features/profile/presentation/setting_page.dart';

import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';

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

  static const surfaceGreen = Color(0xFFEFFAF3);

  static const LinearGradient accentGrad = LinearGradient(
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ProfilePagePro extends ConsumerStatefulWidget {
  const ProfilePagePro({super.key});

  @override
  ConsumerState<ProfilePagePro> createState() => _ProfilePageProState();
}

class _ProfilePageProState extends ConsumerState<ProfilePagePro> {
  String _fullName = "";
  String _email = "";
  String _phone = "";
  String _address = "";

  final _memberSince = "Sep 2024";

  String? _profilePictureFilename;
  File? _localAvatarFile;

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSession());
  }

  Future<void> _loadSession() async {
    try {
      await ref.read(authRemoteDatasourceProvider).getMe();
    } catch (_) {}

    final session = ref.read(userSessionServiceProvider);
    final data = session.getUserData();

    if (!mounted) return;
    setState(() {
      _fullName = data["name"] ?? "";
      _email = data["email"] ?? "";
      _phone = data["contact"] ?? "";
      _address = data["address"] ?? "";
      _profilePictureFilename = data["profilePicture"];
    });
  }

  String? get _avatarUrl {
    final filename = _profilePictureFilename;
    if (filename == null || filename.trim().isEmpty) return null;

    final host = ApiEndpoints.baseUrl.replaceFirst("/api", "");
    final bust = DateTime.now().millisecondsSinceEpoch;
    return "$host/public/profile_photo/$filename?t=$bust";
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
          centerTitle: true,
          title: const Text(
            "Profile",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                accent: AppColors.primaryGreen,
                accent2: AppColors.secondaryGreen,
                name: _fullName.isNotEmpty ? _fullName : "—",
                subtitle: "Member since $_memberSince",
                avatar: _buildAvatarProvider(),
                onAvatarTap: _isUploading ? () {} : _onAvatarTap,
                onEditProfileTap: _onEditProfileTap,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: "Registration Details",
                child: Column(
                  children: [
                    _InfoRow(
                      label: "Full Name",
                      value: _fullName.isNotEmpty ? _fullName : "—",
                    ),
                    _InfoRow(
                      label: "Email",
                      value: _email.isNotEmpty ? _email : "—",
                    ),
                    _InfoRow(
                      label: "Phone",
                      value: _phone.isNotEmpty ? _phone : "—",
                    ),
                    _InfoRow(
                      label: "Address",
                      value: _address.isNotEmpty ? _address : "—",
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _SectionCard(
                title: "Quick Actions",
                child: Column(
                  children: [
                    _ActionTile(
                      accent: AppColors.primaryGreen,
                      icon: Icons.directions_car_outlined,
                      title: "Add / Edit Vehicle",
                      subtitle: "Manage your vehicles and details",
                      onTap: _onAddEditVehicleTap,
                    ),
                    const _DividerSoft(),
                    _ActionTile(
                      accent: AppColors.primaryGreen,
                      icon: Icons.edit_outlined,
                      title: "Edit Profile",
                      subtitle: "Update your personal information",
                      onTap: _onEditProfileTap,
                    ),
                    const _DividerSoft(),
                    _ActionTile(
                      accent: AppColors.primaryGreen,
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      subtitle: "Privacy, notifications, preferences",
                      onTap: _onSettingsTap,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _DangerZone(onLogout: _onLogoutTap),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  ImageProvider _buildAvatarProvider() {
    if (_localAvatarFile != null) return FileImage(_localAvatarFile!);

    final url = _avatarUrl;
    if (url != null && url.trim().isNotEmpty) return NetworkImage(url);

    return const AssetImage("assets/images/avatar_placeholder.png");
  }

  void _onAvatarTap() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderSofter,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Profile picture",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _BottomSheetAction(
                  icon: Icons.visibility_outlined,
                  title: "View photo",
                  onTap: () {
                    Navigator.pop(context);
                    _openAvatarPreview();
                  },
                ),
                _BottomSheetAction(
                  icon: Icons.photo_camera_outlined,
                  title: "Take photo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadAvatar(source: ImageSource.camera);
                  },
                ),
                _BottomSheetAction(
                  icon: Icons.photo_library_outlined,
                  title: "Choose from gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadAvatar(source: ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAvatarPreview() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: InteractiveViewer(
                  child: Image(
                    image: _buildAvatarProvider(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar({required ImageSource source}) async {
    final picker = ImagePicker();

    try {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;

      final file = File(picked.path);

      setState(() {
        _localAvatarFile = file;
        _isUploading = true;
      });

      final filename = await ref
          .read(authRemoteDatasourceProvider)
          .uploadProfilePicture(file);

      await ref.read(userSessionServiceProvider).saveProfilePicture(filename);

      if (!mounted) return;
      setState(() {
        _profilePictureFilename = filename;
        _localAvatarFile = null;
        _isUploading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile photo updated")));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _onEditProfileTap() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );

    if (updated == true) {
      await _loadSession();
    }
  }

  void _onAddEditVehicleTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyCarsPage()),
    );
  }

  void _onSettingsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPagePro()),
    );
  }

  Future<void> _onLogoutTap() async {
    await ref.read(authViewModelProvider.notifier).logout();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.accent,
    required this.accent2,
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.onAvatarTap,
    required this.onEditProfileTap,
  });

  final Color accent;
  final Color accent2;
  final String name;
  final String subtitle;
  final ImageProvider avatar;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Stack(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.18), accent2.withOpacity(0.06)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 6),
                _AvatarFacebookStyle(
                  accent: accent,
                  avatar: avatar,
                  onTap: onAvatarTap,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onEditProfileTap,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFacebookStyle extends StatelessWidget {
  const _AvatarFacebookStyle({
    required this.accent,
    required this.avatar,
    required this.onTap,
  });

  final Color accent;
  final ImageProvider avatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.35), width: 2),
                  image: DecorationImage(image: avatar, fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSofter, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: accent,
                  size: 20,
                ),
              ),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: Padding(
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
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.18)),
              ),
              child: Icon(icon, color: accent),
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
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerSoft extends StatelessWidget {
  const _DividerSoft();
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: AppColors.borderLight);
  }
}

class _BottomSheetAction extends StatelessWidget {
  const _BottomSheetAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFDC2626) : AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w900, color: color),
      ),
      onTap: onTap,
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Account",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: BorderSide(
                  color: const Color(0xFFDC2626).withOpacity(0.25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
