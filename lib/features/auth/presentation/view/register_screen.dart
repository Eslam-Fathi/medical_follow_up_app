import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';

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
  String _selectedRole = 'PATIENT';
  Map<String, dynamic> _doctorDetails = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _showDoctorDetailsDialog() async {
    final licenseController = TextEditingController(text: _doctorDetails['licenseNumber']?.toString() ?? '');
    final specController = TextEditingController(text: _doctorDetails['specialization']?.toString() ?? '');
    final expController = TextEditingController(text: _doctorDetails['yearsOfExperience']?.toString() ?? '');

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Doctor Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: specController,
                decoration: const InputDecoration(labelText: 'Specialization', hintText: 'e.g. Cardiology'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: licenseController,
                decoration: const InputDecoration(labelText: 'License Number', hintText: 'e.g. DOC123456'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: expController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Years of Experience'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (licenseController.text.trim().isEmpty || specController.text.trim().isEmpty || expController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required')),
                  );
                } else {
                  Navigator.of(context).pop({
                    'licenseNumber': licenseController.text.trim(),
                    'specialization': specController.text.trim(),
                    'yearsOfExperience': int.tryParse(expController.text.trim()) ?? 0,
                  });
                }
              },
              child: const Text('Save & Continue'),
            ),
          ],
        );
      },
    );
  }

Future<void> _onRegisterPressed() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedRole == 'DOCTOR') {
    final details = await _showDoctorDetailsDialog();
    if (details == null) {
      return; // Cancelled
    }
    setState(() {
      _doctorDetails = details;
    });
  }

  final notifier = ref.read(authNotifierProvider.notifier);
  await notifier.register(
    name: _nameController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text,
    role: _selectedRole,
  );

  final state = ref.read(authNotifierProvider);
  if (!mounted) return;

  if (state.loginResponse != null) {
    
    // Submit Doctor Profile Appilcation after user creation if DOCTOR
    if (_selectedRole == 'DOCTOR') {
      try {
        final doctorApi = ref.read(doctorApiProvider);
        await doctorApi.createDoctorProfile(
          userId: state.loginResponse!.user.id,
          specialization: _doctorDetails['specialization'],
          licenseNumber: _doctorDetails['licenseNumber'],
          yearsOfExperience: _doctorDetails['yearsOfExperience'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor application submitted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit doctor profile: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created for ${state.loginResponse!.user.name}')),
      );
    }

    if (_selectedRole == 'PATIENT') {
      Navigator.of(context).pushReplacementNamed('/patient_form');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
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
                  // Text('Create Account', style: theme.textTheme.headlineSmall),
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

                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'PATIENT', label: Text('Patient')),
                        ButtonSegment(value: 'DOCTOR', label: Text('Doctor')),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedRole = newSelection.first;
                        });
                      },
                    ),
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

                  // TextButton(
                  //   onPressed: state.isLoading ? null : widget.onLoginTap,
                  //   child: const Text('Already have an account? Login'),
                  // ),
                ],
              ),
            ),
          ),
        ),
      )
    ;
  }
}
