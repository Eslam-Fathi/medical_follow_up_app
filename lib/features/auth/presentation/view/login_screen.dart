import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_state.dart';


/// The login form widget for existing users to authenticate.
///
/// ### Responsibilities (UI only — no business logic)
/// - Renders an email [TextFormField] and a password [TextFormField].
/// - Provides client-side form validation (non-empty checks).
/// - Toggles password visibility with a suffix icon button.
/// - Displays a loading spinner and disables the button while [AuthState.isLoading].
/// - Shows an error banner when [AuthState.error] is non-null.
///
/// ### Architecture: "dumb" view
/// This widget intentionally contains **no** network or navigation logic.
/// All state management is delegated to [AuthNotifier] via `ref.read/watch`.
/// After a successful login, [_onLoginPressed] inspects the resulting [AuthState]
/// to determine which route to push (admin dashboard vs. home screen).
///
/// ### How it fits in the auth flow
/// [LoginScreen] is instantiated **inside** [AuthSwitcher], not pushed as a route.
/// [onCreateAccountTap] is a callback from [AuthSwitcher] that toggles to the
/// [RegisterScreen] when the user taps "Don't have an account?".
class LoginScreen extends ConsumerStatefulWidget {
  /// A callback that tells [AuthSwitcher] to switch to [RegisterScreen].
  ///
  /// Passed down from [AuthSwitcher._toggle] and used by the "Create account"
  /// link (currently commented out but wired up for future use).
  final VoidCallback onCreateAccountTap;

  const LoginScreen({
    super.key,
    required this.onCreateAccountTap,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Key for the [Form] widget; used to trigger validation programmatically.
  ///
  /// `_formKey.currentState!.validate()` runs all field validators and returns
  /// `true` only if none of them returned an error string.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the email input field.
  ///
  /// [TextEditingController] holds the current text and is disposed when the
  /// widget is removed from the tree to avoid memory leaks.
  final _emailController = TextEditingController();

  /// Controller for the password input field.
  final _passwordController = TextEditingController();

  /// Whether the password is hidden (obscured) or visible.
  ///
  /// This is **local UI state** — it does not need to survive widget rebuilds
  /// or be shared with other widgets, so [setState] is appropriate here rather
  /// than a Riverpod provider.
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Always dispose controllers to release the memory they hold.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Called when the user presses the "Login" button.
  ///
  /// **Steps:**
  /// 1. Validate the form. If invalid (e.g. empty fields), stop and let the
  ///    field-level error messages guide the user.
  /// 2. Delegate the actual login to [AuthNotifier.login].
  /// 3. After the future completes, read the current [AuthState]:
  ///    - `SUPER_ADMIN` → navigate to `/admin_dashboard`.
  ///    - Any other role → navigate to `/home`.
  ///    - Error → the state's `error` field is shown via `ref.listen` (see below).
  Future<void> _onLoginPressed() async {
    // Step 1: Validate all form fields before making a network call.
    if (!_formKey.currentState!.validate()) return;

    try {
      // Step 2: Trigger the login. AuthNotifier updates state asynchronously.
      await ref.read(authNotifierProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // Step 3: Read the resulting state after the await.
      final state = ref.read(authNotifierProvider);
      if (!mounted) return; // Guard against calling setState on disposed widget.
      if (state.loginResponse != null) {
        if (state.loginResponse!.user.role == 'SUPER_ADMIN') {
          Navigator.of(context).pushReplacementNamed('/admin_dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch the entire auth state to reactively update the button/spinner.
    final state = ref.watch(authNotifierProvider);

    // Listen for error changes (triggered by a failed login) and show a SnackBar.
    // Using `ref.listen` here (not watch) means this side-effect only runs
    // when the value *changes*, not on every rebuild.
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.error != null) {
        final message = next.error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return Center(
      child: ConstrainedBox(
        // Cap the form width at 420 px for readability on wide screens.
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),

                // ── Email field ───────────────────────────────────────────
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  // Basic non-empty validation. More thorough email format
                  // validation could be added here (e.g. regex or `email_validator`).
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Password field with show/hide toggle ─────────────────
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Swap the icon to indicate the current visibility state.
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  // obscureText replaces each character with a bullet (•).
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password required';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ── Error banner from AuthState ───────────────────────────
                // Shown inline in the form (in addition to the SnackBar above)
                // for a more prominent, accessible error presentation.
                if (state.error != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: theme.colorScheme.error, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 64),

                // ── Submit button ─────────────────────────────────────────
                // While loading: button is disabled + shows a spinner.
                // Normally: shows "Login" text.
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _onLoginPressed,
                    child: state.isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('Please wait...'),
                            ],
                          )
                        : const Text('Login'),
                  ),
                ),

                const SizedBox(height: 12),
                // "Create account" link — currently commented out because
                // switching is handled by the tab bar in AuthSwitcher.
              ],
            ),
          ),
        ),
      ),
    );
  }
}
