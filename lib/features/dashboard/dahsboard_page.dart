import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/app/theme/color.dart';
import 'package:wheels_flutter/core/constants/app_constants.dart';
import 'package:wheels_flutter/features/auth/presentation/pages/login_pages.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/profile/profile_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  void _goToTab(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();

    //  No UI changes — only navigation wiring
    _pages = [
      DashboardHome(onGoToTab: _goToTab),
      Container(
        color: Colors.blue,
        child: const Center(child: Text('Services')),
      ),
      Container(
        color: Colors.green,
        child: const Center(child: Text('Bookings')),
      ),

      const ProfilePagePro(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(authViewModelProvider).authEntity;
      if (currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.design_services_outlined),
      activeIcon: Icon(Icons.design_services),
      label: 'Services',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Bookings',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final currentUser = authState.authEntity;

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: _bottomNavItems,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

class DashboardHome extends ConsumerWidget {
  final void Function(int index) onGoToTab;

  const DashboardHome({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final currentUser = ref.watch(currentUserProvider);

    final double vehicleHeight = width < 360
        ? 340
        : width < 600
        ? 320
        : 340;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(width * 0.045, 14, width * 0.045, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              name: currentUser?.name ?? 'User',
              onLogout: () {
                ref.read(authViewModelProvider.notifier).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: vehicleHeight,
              child: PageView(
                children: [
                  _buildVehicleCard(
                    context,
                    AppConstants.primaryGreen,
                    'Mercedes-Benz',
                    'Oct 15 2019',
                    '2000 km',
                    '3 yrs 6 months',
                  ),
                  _buildVehicleCard(
                    context,
                    AppConstants.pinkAccent,
                    'BMW X5',
                    'Jan 10 2020',
                    '1500 km',
                    '3 yrs 2 months',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SearchBar(onTap: () => onGoToTab(1)),
            const SizedBox(height: 16),

            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final maxW = constraints.maxWidth;

                final int columns = maxW >= 560
                    ? 3
                    : maxW >= 360
                    ? 2
                    : 1;

                final itemWidth = columns == 1
                    ? maxW
                    : (maxW - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _QuickActionCard(
                        icon: Icons.design_services_outlined,
                        title: 'Services',
                        subtitle: 'Explore',
                        onTap: () => onGoToTab(1),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _QuickActionCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Bookings',
                        subtitle: 'My schedule',
                        onTap: () => onGoToTab(2), //  tab navigation
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _QuickActionCard(
                        icon: Icons.shopping_cart_outlined,
                        title: 'Cart',
                        subtitle: 'My items',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartPage()),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: maxW,
                      child: _QuickActionCard(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        subtitle: 'Manage account',
                        onTap: () => onGoToTab(3), //  tab navigation
                        wide: true,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),

            Text(
              'Recommended for you',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _RecommendationTile(
              icon: Icons.local_offer_outlined,
              title: 'Seasonal Service Offer',
              subtitle: 'Save on maintenance this week',
              onTap: () => onGoToTab(1), //  go to Services
            ),
            const SizedBox(height: 10),
            _RecommendationTile(
              icon: Icons.support_agent_outlined,
              title: 'Need help?',
              subtitle: 'Chat with support for quick guidance',
              onTap: () => onGoToTab(3), //  go to Profile (support entry point)
            ),
          ],
        ),
      ),
    );
  }

  //  Vehicle card: overflow-proof (vertical + horizontal)
  Widget _buildVehicleCard(
    BuildContext context,
    Color bgColor,
    String name,
    String date,
    String distance,
    String usage,
  ) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    //  Slightly reduce image size on very small screens (prevents vertical tightness)
    final double carHeight = width < 360 ? 140 : (width < 600 ? 150 : 170);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            //  tuned for more breathing room and less chance of overflow
            margin: const EdgeInsets.only(top: 62),
            padding: const EdgeInsets.fromLTRB(20, 96, 20, 22),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                //  rows are now overflow-safe (both sides flexible)
                _infoRow('Purchased on', date),
                _infoRow('Total Distance', distance),
                _infoRow('Years of use', usage),
              ],
            ),
          ),
          Positioned(
            top: -12,
            child: Image.asset(AppConstants.carImage, height: carHeight),
          ),
        ],
      ),
    );
  }

  //  FIX: both label/value flexible -> no horizontal overflow ever
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------
// Header (UNCHANGED)
// --------------------
class _Header extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;

  const _Header({required this.name, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hi,',
                  style: TextStyle(
                    color: Color(0xFFE8F6E8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            color: Colors.white,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}

// --------------------
// Search Bar (UNCHANGED, safe ellipsis)
// --------------------
class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0E000000),
              blurRadius: 14,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.textTertiary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search services, bookings...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.tune, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// --------------------
// Quick Action Card (overflow-safe)
// --------------------
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool wide;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceGreen,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(icon, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );

    return GestureDetector(onTap: onTap, child: child);
  }
}

// --------------------
// Recommendation Tile (safe ellipsis)
// --------------------
class _RecommendationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RecommendationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0E000000),
              blurRadius: 14,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// --------------------
// Cart Page (simple placeholder route)
// --------------------
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(child: Text('Cart')),
    );
  }
}
