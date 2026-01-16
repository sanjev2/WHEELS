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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialize pages
    _pages = [
      const DashboardHome(),
      // TODO: Add other pages when you create them
      // const DashboardServices(),
      // const DashboardBookings(),
      // const DashboardProfile(),
      Container(
        color: Colors.blue,
        child: const Center(child: Text('Services')),
      ),
      Container(
        color: Colors.green,
        child: const Center(child: Text('Bookings')),
      ),
      Container(
        color: Colors.orange,
        child: const Center(child: Text('Profile')),
      ),
    ];

    // Check authentication on page load
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

    // Redirect to login if user is not authenticated
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
      appBar: _selectedIndex == 0
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
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --------------------
// Home Page
// --------------------
class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final currentUser = ref.watch(currentUserProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(width * 0.04, 20, width * 0.04, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      currentUser?.name ??
                          'User', // Changed from fullName to name
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
            ),
            const SizedBox(height: 20),
            // Vehicle PageView
            SizedBox(
              height: width < 600 ? 300 : 340,
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
          ],
        ),
      ),
    );
  }

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
}
