import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_state.dart';


/// LoginScreen only handles UI & form.
/// All network/auth logic is in AuthNotifier.
/// The login interface for users to access their accounts.
/// 
/// It handles email and password input, form validation, and displays 
/// authentication errors. Logic is delegated to [AuthNotifier].
class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onCreateAccountTap;

  const LoginScreen({
    super.key,
    required this.onCreateAccountTap,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: 'admin@medical.com'); // test creds
  final _passwordController =
      TextEditingController(text: 'Admin123456'); // test creds

  bool _obscurePassword = true; // local UI state only

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Called when user presses the login button.
  /// Delegates work to AuthNotifier.
 Future<void> _onLoginPressed() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    await ref.read(authNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    final state = ref.read(authNotifierProvider);
    if (!mounted) return;
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
    final state = ref.watch(authNotifierProvider);
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
    if (next.error != null) {
      final message = next.error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  });

    return 
       Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text('MedME Login', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 24),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password with show/hide toggle
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
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
                    obscureText: _obscurePassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Error from AuthState, if any
                  if (state.error != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
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

                  // Login button with loading indicator
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
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
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

                  // Switch to register
                  // TextButton(
                  //   onPressed:
                  //       state.isLoading ? null : widget.onCreateAccountTap,
                  //   child: const Text("Don't have an account? Create one"),
                  // ),
                ],
              ),
            ),
          ),
        ),
      
       );
  }
}
