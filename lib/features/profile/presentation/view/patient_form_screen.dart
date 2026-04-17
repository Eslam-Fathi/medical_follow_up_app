import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  const PatientFormScreen({super.key});

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGender = 'MALE';
  String _selectedBloodType = 'O+';

  bool _isLoading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _chronicDiseasesController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authNotifierProvider);
    final userId = authState.loginResponse?.user.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not found.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patientApi = ref.read(patientApiProvider);
      final displayId = 'P-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      await patientApi.createPatientProfile(
        userId: userId,
        displayId: displayId,
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        bloodType: _selectedBloodType,
        chronicDiseases: _chronicDiseasesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        allergies: _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile completed successfully!')),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
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
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: Center(
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
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Age is required';
                      if (int.tryParse(v) == null) return 'Must be a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    value: _selectedGender,
                    items: const [
                      DropdownMenuItem(value: 'MALE', child: Text('Male')),
                      DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGender = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Blood Type'),
                    value: _selectedBloodType,
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((bt) => DropdownMenuItem(value: bt, child: Text(bt)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBloodType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _chronicDiseasesController,
                    decoration: const InputDecoration(labelText: 'Chronic Diseases (comma separated)', hintText: 'e.g. Diabetes, Hypertension'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(labelText: 'Allergies (comma separated)', hintText: 'e.g. Penicillin, Peanuts'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Additional Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
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
