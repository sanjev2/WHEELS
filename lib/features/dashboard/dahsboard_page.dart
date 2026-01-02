import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/app/theme/color.dart';
import 'package:wheels_flutter/core/constants/app_constants.dart';
import 'package:wheels_flutter/features/auth/presentation/pages/login_pages.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  // Define your pages/screens here
  final List<Widget> _pages = [
    const DashboardHome(),
    const DashboardServices(),
    const DashboardBookings(),
    const DashboardProfile(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.design_services_outlined),
      activeIcon: Icon(Icons.design_services),
      label: 'Services',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Bookings',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Check authentication on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      if (!isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar:
          _selectedIndex ==
              0 // Show app bar only on home page
          ? AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Dashboard'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ref.read(authViewModelProvider.notifier).logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              ],
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

// Home Page (Existing Dashboard Content)
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(width * 0.04, 20, width * 0.04, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 20),
            _buildVehiclePageView(context),
            const SizedBox(height: 32),
            _buildServicesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 20,
                color: AppConstants.darkGreen,
              ),
            ),
            Text(
              'User Name', // You can pass the actual user name here
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppConstants.darkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          iconSize: 26,
          color: AppConstants.primaryGreen,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildVehiclePageView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: width < 600 ? 300 : 340,
      child: PageView(
        children: [
          _buildVehicleCard(
            context: context,
            bgColor: AppConstants.primaryGreen,
            name: 'Mercedes-Benz',
            date: 'Oct 15 2019',
            distance: '2000 km',
            usage: '3 yrs 6 months',
          ),
          _buildVehicleCard(
            context: context,
            bgColor: AppConstants.pinkAccent,
            name: 'BMW X5',
            date: 'Jan 10 2020',
            distance: '1500 km',
            usage: '3 yrs 2 months',
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard({
    required BuildContext context,
    required Color bgColor,
    required String name,
    required String date,
    required String distance,
    required String usage,
  }) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.fromLTRB(20, 90, 20, 24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow('Purchased on', date),
                _infoRow('Total Distance', distance),
                _infoRow('Years of use', usage),
              ],
            ),
          ),
          Positioned(
            top: -10,
            child: Image.asset(
              AppConstants.carImage,
              height: width < 600 ? 150 : 170,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    final int crossAxisCount = width < 400
        ? 2
        : width < 600
        ? 3
        : 4;

    final double iconBoxSize = width < 360
        ? 40
        : width < 420
        ? 48
        : width < 600
        ? 56
        : 64;

    Widget serviceItem(IconData icon, String title) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppConstants.surfaceGreen,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: iconBoxSize * 0.55,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.3,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Services',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final icons = [
              Icons.car_repair,
              Icons.settings,
              Icons.battery_charging_full,
              Icons.tire_repair,
              Icons.build,
              Icons.checklist,
              Icons.cleaning_services,
              Icons.search,
            ];

            final titles = [
              'Periodic Servicing',
              'AC Service & Repair',
              'Batteries',
              'Tyres & Wheel Care',
              'Denting & Painting',
              'Detailing Services',
              'Car Spa & Cleaning',
              'Car Inspections',
            ];

            return serviceItem(icons[index], titles[index]);
          },
        ),
      ],
    );
  }
}

// Services Page
class DashboardServices extends StatelessWidget {
  const DashboardServices({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Services Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Bookings Page
class DashboardBookings extends StatelessWidget {
  const DashboardBookings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Bookings Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Profile Page
class DashboardProfile extends ConsumerWidget {
  const DashboardProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryGreen,
              child: Text(
                currentUser?.fullName?.substring(0, 1) ?? 'U',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentUser?.fullName ?? 'User Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              currentUser?.email ?? 'user@email.com',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            _buildProfileItem(Icons.person, 'Personal Info'),
            _buildProfileItem(Icons.history, 'Booking History'),
            _buildProfileItem(Icons.settings, 'Settings'),
            _buildProfileItem(Icons.help, 'Help & Support'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authViewModelProvider.notifier).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Handle tap for each profile item
        },
      ),
    );
  }
}
