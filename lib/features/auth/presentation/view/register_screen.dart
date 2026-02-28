import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';

/// RegisterScreen for creating a new user (PATIENT by default).
class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterScreen({
    super.key,
    required this.onLoginTap,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _onRegisterPressed() async {
  if (!_formKey.currentState!.validate()) return;

  final notifier = ref.read(authNotifierProvider.notifier);
  await notifier.register(
    name: _nameController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text,
    role: 'PATIENT',
  );

  final state = ref.read(authNotifierProvider);
  if (!mounted) return;

  if (state.loginResponse != null) {
    final user = state.loginResponse!.user;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account created for ${user.name}')),
    );

    
    Navigator.of(context).pushReplacementNamed('/home');
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(authNotifierProvider);

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
                  Text('Create Account', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Email required' : null,
                  ),
                  const SizedBox(height: 16),

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
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Password required' : null,
                  ),
                  const SizedBox(height: 16),

                  if (state.error != null)
                    Text(
                      state.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          state.isLoading ? null : _onRegisterPressed,
                      child: state.isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : const Text('Create account'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: state.isLoading ? null : widget.onLoginTap,
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    ;
  }
}
