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

/// A [GlobalKey] that provides access to the [NavigatorState] from outside the
/// widget tree (e.g. from a service or a Riverpod notifier).
///
/// ### Why a global navigator key?
/// Normally, navigation in Flutter requires a [BuildContext] to call
/// `Navigator.of(context).push(...)`. However, some parts of the app need to
/// navigate without direct access to a widget's context:
/// - [GlobalNotificationWrapper] needs to intercept appointment notifications
///   and push the relevant screen.
/// - [MedME]'s `ref.listen` block runs outside the build tree and needs to
///   redirect to `/auth` on logout.
///
/// By passing this key to [MaterialApp.navigatorKey], we gain access to the
/// navigator's state from anywhere via `navigatorKey.currentState`.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// The entry point of the AuraMed / MedME application.
///
/// ### App startup sequence
/// 1. [WidgetsFlutterBinding.ensureInitialized] — Must be called before any
///    asynchronous Flutter APIs are used (required for plugins, file I/O, etc.).
/// 2. [dotenv.load] — Loads environment variables from the `.env` file at the
///    project root. This is where API keys and secrets are kept out of version
///    control. (e.g. the Gemini API key for the chatbot.)
/// 3. [NotificationService().init()] — Initializes the local notifications
///    plugin and registers the Android notification channel. Must happen before
///    [runApp] so the channel exists before any notification is scheduled.
/// 4. [runApp] — Starts the widget tree. The entire app is wrapped in a
///    [ProviderScope], which is required by Riverpod. Every `ref.watch/read`
///    call in the app communicates through this single scope.
Future<void> main() async {
  // Ensures the native platform bindings are initialized before using plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // Load key=value pairs from the `.env` file into `dotenv.env`.
  // Access them with: `dotenv.env['KEY_NAME']`
  await dotenv.load(fileName: ".env");

  // Initialize local notifications (Android channel, iOS permissions, timezone).
  await NotificationService().init();

  // ProviderScope is the Riverpod dependency injection container.
  // All providers are created lazily within this scope.
  runApp(const ProviderScope(child: MedME()));
}

/// The root widget of the AuraMed application.
///
/// ### What this widget does
/// 1. **Global logout listener** — Uses `ref.listen` on [authNotifierProvider]
///    to detect when the user logs out (i.e. `loginResponse` transitions from
///    non-null to null). When this happens, it clears the navigation stack
///    and pushes the auth screen using [navigatorKey].
///
/// 2. **Theme** — Watches [themeModeProvider] to reactively apply the current
///    theme mode (light/dark/system) to [MaterialApp.themeMode].
///
/// 3. **MaterialApp configuration**:
///    - `navigatorKey` — Enables global navigation from outside the widget tree.
///    - `builder` — Wraps the entire widget tree in [GlobalNotificationWrapper],
///      which intercepts in-app appointment notification banners.
///    - `scrollBehavior` — Applies [NoScrollbarScrollBehavior] globally so all
///      scrollable widgets follow the same rules (no scrollbar on mobile,
///      scrollbar + mouse-drag on web).
///    - `routes` — A named route table for predictable, decoupled navigation.
///    - `onUnknownRoute` — Falls back to [NotFoundScreen] for any unrecognized
///      route name, preventing a hard crash.
///
/// ### Why [ConsumerWidget]?
/// [ConsumerWidget] is the Riverpod equivalent of a [StatelessWidget] that can
/// watch providers. The `build` method receives a [WidgetRef] (`ref`) that grants
/// access to the Riverpod provider graph.
class MedME extends ConsumerWidget {
  const MedME({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Global Logout Listener ─────────────────────────────────────────────
    // `ref.listen` runs a callback whenever the watched value changes.
    // This is different from `ref.watch` (which rebuilds the widget).
    //
    // The condition: `previous?.loginResponse != null && next.loginResponse == null`
    // fires ONLY when the user transitions FROM authenticated TO unauthenticated.
    // This handles both manual logout and token expiration.
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous?.loginResponse != null && next.loginResponse == null) {
        // User just logged out or session became invalid.
        // `pushNamedAndRemoveUntil('/auth', (route) => false)` clears the
        // entire navigation stack and pushes auth, so the back button
        // cannot return to the home screen after logout.
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
      }
    });

    final currentThemeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      // Pass the global key so we can navigate from outside the widget tree.
      navigatorKey: navigatorKey,

      // The `builder` wraps every route's content in GlobalNotificationWrapper.
      // This gives the notification system access to the Navigator for pushes.
      builder: (context, child) {
        return GlobalNotificationWrapper(
          navigatorKey: navigatorKey,
          child: child ?? const SizedBox(),
        );
      },

      // Apply the custom scroll behavior globally (see scroll_bar_behavior.dart).
      scrollBehavior: NoScrollbarScrollBehavior(),

      title: 'MediTrack',

      // The light and dark ThemeData objects are defined in:
      // - core/theme/light_theme_data.dart
      // - core/theme/dark_theme_data.dart
      theme: healtecLightTheme,
      darkTheme: healtecDarkTheme,

      // Reactively switches between light/dark/system based on themeModeProvider.
      themeMode: currentThemeMode,

      // Remove the red "DEBUG" banner from the top-right corner in debug builds.
      debugShowCheckedModeBanner: false,

      // The first widget shown is StartPoint, which displays the splash screen
      // and decides where to navigate after checking auth status.
      home: const StartPoint(),

      // ── Named Route Table ────────────────────────────────────────────────
      // Named routes decouple navigation: screens push `'/home'` by string
      // rather than importing and constructing the target widget directly.
      routes: {
        '/auth': (_) => const AuthSwitcher(),
        '/home': (_) => const HomeFollowUpScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/patient_form': (_) => const PatientFormScreen(),
        '/admin_dashboard': (_) => const AdminDashboardScreen(),
        '/doctors_list': (_) => const DoctorsListScreen(),
      },

      // Fallback for any route name not found in the table above.
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const NotFoundScreen());
      },
    );
  }
}

/// The very first widget the user sees: the animated splash screen.
///
/// ### What it does
/// 1. Shows [MedSplashScreen] (an animated logo + loading spinner).
/// 2. Calls [_checkAuth] asynchronously **after** the first frame is rendered
///    (via [WidgetsBinding.addPostFrameCallback]). This ensures the splash
///    animation starts before any blocking I/O begins.
/// 3. Enforces a minimum 2500ms display duration so the splash screen is
///    visible long enough to be intentional — not just a flash.
/// 4. Navigates to the correct first screen based on auth status and user role.
///
/// ### Why a ConsumerStatefulWidget?
/// [ConsumerStatefulWidget] is Riverpod's [StatefulWidget] base class. It gives
/// `_StartPointState` access to `ref` in lifecycle methods like [initState] and
/// lets [_checkAuth] read providers without a [BuildContext].
class StartPoint extends ConsumerStatefulWidget {
  const StartPoint({super.key});

  @override
  ConsumerState<StartPoint> createState() => _StartPointState();
}

class _StartPointState extends ConsumerState<StartPoint> {
  @override
  void initState() {
    super.initState();
    // Schedule _checkAuth after the first frame so the splash screen is
    // painted before any async I/O blocks the thread.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  /// Determines the correct initial route by checking auth status and
  /// pre-fetching essential data for a seamless transition.
  ///
  /// **Flow:**
  /// ```
  /// checkAuthStatus()
  ///   ├─ Not logged in → navigate to /auth
  ///   └─ Logged in
  ///       ├─ SUPER_ADMIN → prefetch pendingDoctors → /admin_dashboard
  ///       └─ Patient/Doctor → prefetch profile + appointments
  ///           ├─ success → warm up chat cache (background) → /home
  ///           └─ failure (e.g. 401) → logout() → /auth
  /// ```
  ///
  /// **Minimum splash duration:** We record the start time and, after all
  /// async work is done, wait for any remaining time up to 2500ms. This
  /// prevents the splash from disappearing too quickly on fast devices while
  /// still not wasting time on slow devices.
  Future<void> _checkAuth() async {
    final startTime = DateTime.now();

    final notifier = ref.read(authNotifierProvider.notifier);

    // Step 1: Try to restore a persisted session from SharedPreferences.
    await notifier.checkAuthStatus();

    final state = ref.read(authNotifierProvider);

    if (state.loginResponse != null) {
      try {
        if (state.loginResponse!.user.role == 'SUPER_ADMIN') {
          // Pre-load pending doctors so the admin dashboard renders immediately.
          await ref.read(pendingDoctorsProvider.future);
        } else {
          // For patients and doctors: pre-load profile and appointments in parallel.
          // `Future.wait` runs both futures concurrently, saving time vs. sequential.
          await Future.wait([
            ref.read(profileProvider.future),
            ref.read(appointmentsProvider.future),
          ]);

          // Warm up the chat cache in the background (fire-and-forget).
          // This pre-loads recent conversations so the chat tab opens instantly.
          ref.read(chatWarmUpProvider).warmUp();
        }
      } catch (e) {
        // If data loading fails (e.g. the stored token is expired/revoked),
        // force a logout to return the app to a known clean state.
        await notifier.logout();
      }
    }

    // ── Minimum 2500ms Splash Duration ────────────────────────────────────
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remainingDelay = 2500 - elapsed;
    if (remainingDelay > 0) {
      await Future.delayed(Duration(milliseconds: remainingDelay));
    }

    // Guard: if the widget was removed from the tree while we were waiting,
    // do not attempt to navigate (this would throw a 'disposed context' error).
    if (!mounted) return;

    // ── Final Navigation Decision ──────────────────────────────────────────
    // Re-read the state because logout() may have been called in the catch block.
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
    // While _checkAuth runs in the background, show the animated splash screen.
    return const MedSplashScreen();
  }
}
