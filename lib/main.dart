import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheels_flutter/app/theme/app_theme.dart';
import 'package:wheels_flutter/core/api/api_clients.dart';
import 'package:wheels_flutter/core/services/hive/hive_services.dart';
import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:wheels_flutter/features/dashboard/dahsboard_page.dart';
import 'package:wheels_flutter/features/splash/splash_page.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';
import 'package:wheels_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';

/// Define a SharedPreferences provider
final sharedPreferenceProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize UserSessionService
  final userSessionService = UserSessionService(
    sharedPreferences: sharedPreferences,
  );

  // Initialize ApiClient
  final apiClient = ApiClient();

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences
        sharedPreferenceProvider.overrideWithValue(sharedPreferences),

        // Override UserSessionService
        userSessionServiceProvider.overrideWithValue(userSessionService),

        // Override ApiClient
        apiClientProvider.overrideWithValue(apiClient),

        // Override Local Datasource
        authLocalDatasourceProvider.overrideWithValue(
          AuthLocalDatasource(userSessionService: userSessionService),
        ),

        // Override Remote Datasource
        authRemoteDatasourceProvider.overrideWithValue(
          AuthRemoteDatasource(
            apiClient: apiClient,
            userSessionService: userSessionService,
          ),
        ),

        // No need to override authRepositoryProvider if it's already implemented in auth_repository.dart
        // Riverpod will automatically construct AuthRepositoryImpl using the above providers
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth status to determine routing
    final authStatus = ref.watch(authStatusProvider);
    final isLoading = ref.watch(authLoadingProvider);

    // Show loading while checking auth state
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Wheels',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _buildHome(authStatus),
    );
  }

  Widget _buildHome(AuthStatus authStatus) {
    switch (authStatus) {
      case AuthStatus.authenticated:
        return const DashboardPage();
      case AuthStatus.unauthenticated:
      case AuthStatus.initial:
      case AuthStatus.registered:
      case AuthStatus.error:
      default:
        return const SplashPage(); // Splash will redirect to login
    }
  }
}
