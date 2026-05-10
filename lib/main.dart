import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medical_follow_up_app/core/theme/light_theme_data.dart';
import 'package:medical_follow_up_app/core/theme/dark_theme_data.dart';
import 'package:medical_follow_up_app/core/theme/theme_provider.dart';
import 'package:medical_follow_up_app/core/utils/scroll_bar_behavior.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_state.dart';
import 'package:medical_follow_up_app/features/auth/presentation/view/auth_switcher.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/home_screen.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/profile_screen.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/patient_form_screen.dart';
import 'package:medical_follow_up_app/features/admin/presentation/view/admin_dashboard_screen.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/view/doctors_list_screen.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/view/global_notification_wrapper.dart';
import 'package:medical_follow_up_app/core/services/notification_service.dart';
import 'package:medical_follow_up_app/features/chat/presentation/manager/chat_provider.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/core/widgets/med_splash_screen.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/core/widgets/not_found_screen.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/manager/doctor_approval_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService().init();
  runApp(const ProviderScope(child: MedME()));
}

/// The root widget of the application.
/// 
/// It configures the global theme, routing table, and top-level providers.
/// It also listens to authentication state changes to handle global navigation 
/// (e.g., auto-logout).
class MedME extends ConsumerWidget {
  const MedME({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Global listener for logout/auth-state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous?.loginResponse != null && next.loginResponse == null) {
        // User just logged out or session became invalid
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
      }
    });

    final currentThemeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) {
        return GlobalNotificationWrapper(
          navigatorKey: navigatorKey,
          child: child ?? const SizedBox(),
        );
      },
      scrollBehavior: NoScrollbarScrollBehavior(),
      title: 'medicUp',
      theme: healtecLightTheme,
      darkTheme: healtecDarkTheme,
      themeMode: currentThemeMode,
      debugShowCheckedModeBanner: false,
      home: const StartPoint(),
      routes: {
        '/auth': (_) => const AuthSwitcher(),
        '/home': (_) => const HomeFollowUpScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/patient_form': (_) => const PatientFormScreen(),
        '/admin_dashboard': (_) => const AdminDashboardScreen(),
        '/doctors_list': (_) => const DoctorsListScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
        );
      },
    );
  }
}

/// The initial entry point screen that handles authentication check and data warming.
/// 
/// Displays the splash screen while verifying the user's session and 
/// pre-fetching essential data for a seamless transition to the main app.
class StartPoint extends ConsumerStatefulWidget {
  const StartPoint({super.key});

  @override
  ConsumerState<StartPoint> createState() => _StartPointState();
}

class _StartPointState extends ConsumerState<StartPoint> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final startTime = DateTime.now();

    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.checkAuthStatus();

    final state = ref.read(authNotifierProvider);

    if (state.loginResponse != null) {
      try {
        if (state.loginResponse!.user.role == 'SUPER_ADMIN') {
          // Pre-load pending doctors for admin
          await ref.read(pendingDoctorsProvider.future);
        } else {
          // Pre-load profile and appointments for regular users
          await Future.wait([
            ref.read(profileProvider.future),
            ref.read(appointmentsProvider.future),
          ]);
          // Silently warm up chat cache in the background
          ref.read(chatWarmUpProvider).warmUp();
        }
      } catch (e) {
        // If data fails to load (e.g. token expired, network error),
        // we logout to force a clean state
        await notifier.logout();
      }
    }

    // Ensure at least 2500ms has passed for the splash screen animation
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remainingDelay = 2500 - elapsed;
    if (remainingDelay > 0) {
      await Future.delayed(Duration(milliseconds: remainingDelay));
    }

    if (!mounted) return;

    // Check state again after potential data loading and delay
    final finalState = ref.read(authNotifierProvider);
    if (finalState.loginResponse != null) {
      if (finalState.loginResponse!.user.role == 'SUPER_ADMIN') {
        Navigator.of(context).pushReplacementNamed('/admin_dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MedSplashScreen();
  }
}
