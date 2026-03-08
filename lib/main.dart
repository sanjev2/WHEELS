import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:wheels_flutter/app/theme/app_theme.dart';

import 'package:wheels_flutter/core/api/api_clients.dart';
import 'package:wheels_flutter/core/services/hive/hive_services.dart';

import 'package:wheels_flutter/core/services/storage/shared_pref_provider.dart';
import 'package:wheels_flutter/core/services/storage/user_session.dart';

import 'package:wheels_flutter/core/services/storage/active_car_storage.dart';
import 'package:wheels_flutter/core/services/storage/active_car_storage_provider.dart';
import 'package:wheels_flutter/core/services/storage/onboarding_storage.dart';
import 'package:wheels_flutter/core/widgets/accident_alert_dialog.dart';

import 'package:wheels_flutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:wheels_flutter/features/auth/presentation/state/auth_state.dart';

import 'package:wheels_flutter/features/auth/presentation/pages/login_pages.dart';
import 'package:wheels_flutter/features/dashboard/dahsboard_page.dart';
import 'package:wheels_flutter/features/splash/splash_page.dart';
import 'package:wheels_flutter/features/onboarding/onboarding_page.dart';

import 'package:wheels_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:wheels_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterForegroundTask.initCommunicationPort();

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'trip_tracking',
      channelName: 'Trip Tracking',
      channelDescription: 'Tracks trip distance in background',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

  final prefs = await SharedPreferences.getInstance();

  final hiveService = HiveService();
  await hiveService.init();

  final userSessionService = UserSessionService(sharedPreferences: prefs);
  final apiClient = ApiClient();
  final activeCarStorage = ActiveCarStorage(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        activeCarStorageProvider.overrideWithValue(activeCarStorage),
        userSessionServiceProvider.overrideWithValue(userSessionService),
        apiClientProvider.overrideWithValue(apiClient),
        authLocalDatasourceProvider.overrideWithValue(
          AuthLocalDatasource(userSessionService: userSessionService),
        ),
        authRemoteDatasourceProvider.overrideWithValue(
          AuthRemoteDatasource(
            apiClient: apiClient,
            userSessionService: userSessionService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

enum StartRoute { onboarding, app }

final startRouteProvider = FutureProvider<StartRoute>((ref) async {
  await Future.delayed(const Duration(seconds: 3));

  final seen = ref.read(onboardingStorageProvider).hasSeen();
  if (!seen) return StartRoute.onboarding;

  await ref.read(authViewModelProvider.notifier).init();
  return StartRoute.app;
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  bool _dialogOpen = false;
  DateTime? _lastAccidentTrigger;

  static const String sosNumber = '100';
  static const double accidentThreshold = 35.0;
  static const Duration triggerCooldown = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _startAccidentDetection();
  }

  void _startAccidentDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        final double intensity = event.x.abs() + event.y.abs() + event.z.abs();

        final now = DateTime.now();

        final bool inCooldown =
            _lastAccidentTrigger != null &&
            now.difference(_lastAccidentTrigger!) < triggerCooldown;

        if (intensity > accidentThreshold && !_dialogOpen && !inCooldown) {
          _lastAccidentTrigger = now;
          _showAccidentDialog();
        }
      },
      onError: (error) {
        debugPrint('Accelerometer error: $error');
      },
      cancelOnError: false,
    );
  }

  Future<void> _showAccidentDialog() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null || !mounted) return;

    _dialogOpen = true;

    final bool? shouldCall = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'SOS Alert',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Center(
          child: Material(
            color: Colors.transparent,
            child: AccidentAlertDialog(initialSeconds: 10),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );

    _dialogOpen = false;

    if (shouldCall == true) {
      await _makeDirectSOSCall();
    }
  }

  Future<void> _makeDirectSOSCall() async {
    if (!Platform.isAndroid) {
      _showMessage(
        'Direct SOS call is enabled only for Android in this setup.',
      );
      return;
    }

    try {
      final bool? didCall = await FlutterPhoneDirectCaller.callNumber(
        sosNumber,
      );

      if (didCall != true) {
        _showMessage('Could not start SOS call.');
      }
    } catch (e) {
      _showMessage('SOS call failed: $e');
    }
  }

  void _showMessage(String message) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = ref.watch(startRouteProvider);

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Wheels',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: start.when(
        loading: () => const SplashPage(),
        error: (e, _) => Scaffold(body: Center(child: Text('Init error: $e'))),
        data: (route) {
          if (route == StartRoute.onboarding) {
            return const OnboardingPage();
          }
          return const _AuthHome();
        },
      ),
    );
  }
}

class _AuthHome extends ConsumerWidget {
  const _AuthHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    switch (authState.status) {
      case AuthStatus.authenticated:
        return const DashboardPage();

      case AuthStatus.loading:
      case AuthStatus.initial:
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      case AuthStatus.registered:
      default:
        return const LoginPage();
    }
  }
}
