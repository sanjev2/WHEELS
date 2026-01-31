import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wheels_flutter/core/api/api_endpoints.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';
import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:wheels_flutter/features/auth/presentation/pages/login_pages.dart';

/// Accent color: #5A9C41
const kAccentGreen = Color(0xFF5A9C41);

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

  /// ✅ FIXED: correct static folder + cache buster
  String? get _avatarUrl {
    final filename = _profilePictureFilename;
    if (filename == null || filename.trim().isEmpty) return null;

    // ApiEndpoints.baseUrl = http://10.0.2.2:5000/api
    final host = ApiEndpoints.baseUrl.replaceFirst("/api", "");

    // ✅ MUST MATCH backend:
    // app.use("/public", express.static(...))
    // multer saves into: public/profile_photo
    //
    // ✅ Cache-buster so newly uploaded image shows immediately (no stale cache)
    final bust = DateTime.now().millisecondsSinceEpoch;

    return "$host/public/profile_photo/$filename?t=$bust";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: kAccentGreen,
          secondary: kAccentGreen,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Profile",
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                accent: kAccentGreen,
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
                      accent: kAccentGreen,
                      icon: Icons.directions_car_outlined,
                      title: "Add / Edit Vehicle",
                      subtitle: "Manage your vehicles and details",
                      onTap: _onAddEditVehicleTap,
                    ),
                    const _DividerSoft(),
                    _ActionTile(
                      accent: kAccentGreen,
                      icon: Icons.edit_outlined,
                      title: "Edit Profile",
                      subtitle: "Update your personal information",
                      onTap: _onEditProfileTap,
                    ),
                    const _DividerSoft(),
                    _ActionTile(
                      accent: kAccentGreen,
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
    // ✅ show local preview while uploading
    if (_localAvatarFile != null) return FileImage(_localAvatarFile!);

    final url = _avatarUrl;
    if (url != null && url.trim().isNotEmpty) {
      return NetworkImage(url);
    }

    return const AssetImage("assets/images/avatar_placeholder.png");
  }

  void _onAvatarTap() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
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
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Profile picture",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
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

  void _onEditProfileTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Navigate to Edit Profile screen")),
    );
  }

  void _onAddEditVehicleTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Navigate to Add/Edit Vehicle screen")),
    );
  }

  void _onSettingsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Navigate to Settings screen")),
    );
  }

  Future<void> _onLogoutTap() async {
    await ref.read(authRemoteDatasourceProvider).logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}

// UI widgets unchanged below (same as your existing)
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.accent,
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.onAvatarTap,
    required this.onEditProfileTap,
  });

  final Color accent;
  final String name;
  final String subtitle;
  final ImageProvider avatar;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.18), accent.withOpacity(0.06)],
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
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
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
                      style: TextStyle(fontWeight: FontWeight.w800),
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                  color: Color(0xFF111827),
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
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
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
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
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
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
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
    final color = danger ? const Color(0xFFDC2626) : const Color(0xFF111827);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w800, color: color),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
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
