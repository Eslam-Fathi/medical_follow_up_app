import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';

/// Screen shown after login to let a logged‑in user complete
/// their **patient** profile (demographics + medical history).
class PatientFormScreen extends ConsumerStatefulWidget {
  const PatientFormScreen({super.key});

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  /// Global key to validate and save the form.
  final _formKey = GlobalKey<FormState>();

  /// Text controllers for form fields.
  final _ageController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _notesController = TextEditingController();

  /// Currently selected gender (API expects uppercase enums).
  String _selectedGender = 'MALE';

  /// Currently selected blood type (API expects e.g. "O+").
  String _selectedBloodType = 'O+';

  /// Simple local loading flag to disable the button / show spinner.
  bool _isLoading = false;

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks.
    _ageController.dispose();
    _chronicDiseasesController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Validates the form, builds the request payload and calls the
  /// /api/patients endpoint via [patientApiProvider].
  Future<void> _submitForm() async {
    // Abort if any validator reports an error.
    if (!_formKey.currentState!.validate()) return;

    // Get the currently authenticated user from auth state.
    final authState = ref.read(authNotifierProvider);
    final userId = authState.loginResponse?.user.id;

    // Safety check: user should exist at this point.
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: User not found.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Patient API client (wired via Riverpod provider).
      final patientApi = ref.read(patientApiProvider);

      // Human‑friendly display ID, e.g. "P-1234567".
      // Backend will still use its own primary key for the patient.
      final displayId =
          'P-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Build and send the create‑patient request.
      await patientApi.createPatientProfile(
        userId: userId,
        displayId: displayId,
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        bloodType: _selectedBloodType,
        // Split comma‑separated values into clean string lists.
        chronicDiseases: _chronicDiseasesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        allergies: _allergiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        notes: _notesController.text.trim(),
      );

      // After a successful API call, ensure the widget is still in the tree.
      if (!mounted) return;

      // Basic success feedback + redirect to home.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile completed successfully!')),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      // Any error thrown by the API client is surfaced to the user.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      // Always clear loading state if the widget is still active.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Center(
        // ResponsiveWrapper keeps the form nicely centered and constrained
        // on large screens (web/desktop) and full‑width on mobile.
        child: ResponsiveWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Please tell us more about your health.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  /// Age
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Age is required';
                      }
                      if (int.tryParse(v) == null) {
                        return 'Must be a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Gender (MALE/FEMALE – matches backend enum)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    value: _selectedGender,
                    items: const [
                      DropdownMenuItem(value: 'MALE', child: Text('Male')),
                      DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedGender = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Blood type (sent as simple string to API)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Blood Type'),
                    value: _selectedBloodType,
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map(
                          (bt) => DropdownMenuItem(value: bt, child: Text(bt)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedBloodType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Chronic diseases as comma‑separated free text.
                  /// Converted to List<String> before sending to backend.
                  TextFormField(
                    controller: _chronicDiseasesController,
                    decoration: const InputDecoration(
                      labelText: 'Chronic Diseases (comma separated)',
                      hintText: 'e.g. Diabetes, Hypertension',
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Allergies as comma‑separated free text.
                  TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(
                      labelText: 'Allergies (comma separated)',
                      hintText: 'e.g. Penicillin, Peanuts',
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Optional free‑text notes from the patient.
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  /// Primary action button: calls [_submitForm].
                  /// Disabled when a request is in‑flight.
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : const Text('Complete Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
