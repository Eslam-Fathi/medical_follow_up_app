import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';

class MedicalRecordFormScreen extends StatefulWidget {
  final String patientDisplayId;
  final String patientName;

  const MedicalRecordFormScreen({
    super.key,
    required this.patientDisplayId,
    required this.patientName,
  });

  @override
  State<MedicalRecordFormScreen> createState() => _MedicalRecordFormScreenState();
}

class _MedicalRecordFormScreenState extends State<MedicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Overview controllers
  final _departmentCtrl = TextEditingController();
  final _admissionDateCtrl = TextEditingController();
  final _bedNoCtrl = TextEditingController();
  final _allergiesTextCtrl = TextEditingController();
  final _previousSurgeriesCtrl = TextEditingController();
  final _admissionWeightCtrl = TextEditingController();
  final _todayWeightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bmiCtrl = TextEditingController();
  final _admissionReasonCtrl = TextEditingController();
  final _medicalDiagnosisCtrl = TextEditingController();
  final _complicationsCtrl = TextEditingController();

  // Medications
  final _medicationsCtrl = TextEditingController(); // comma separated

  // Respiratory controllers
  final _respTypeCtrl = TextEditingController();
  final _respRhythmCtrl = TextEditingController();
  final _respRateCtrl = TextEditingController();
  final _respPatternCtrl = TextEditingController();
  final _chestExcursionCtrl = TextEditingController();
  final _o2PercentCtrl = TextEditingController();
  final _o2FlowCtrl = TextEditingController();
  final _o2DeviceCtrl = TextEditingController();
  final _bronchialHygieneCtrl = TextEditingController();
  final _o2SatCtrl = TextEditingController();
  final _abgCtrl = TextEditingController();
  final _incentiveSpirometerCtrl = TextEditingController();
  final _mdiInhalerCtrl = TextEditingController();
  final _breathSoundsCtrl = TextEditingController();
  final _coughCtrl = TextEditingController();
  final _chestTubeCtrl = TextEditingController();

  // Cardio controllers
  final _pulseSeriesCtrl = TextEditingController(); // comma separated
  final _pulseRateCtrl = TextEditingController();
  final _pulseRhythmCtrl = TextEditingController();
  final _pulseAmplitudeCtrl = TextEditingController();
  final _heartSoundsCtrl = TextEditingController();
  final _bpSeriesCtrl = TextEditingController();
  final _mapCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _departmentCtrl.dispose();
    _admissionDateCtrl.dispose();
    _bedNoCtrl.dispose();
    _allergiesTextCtrl.dispose();
    _previousSurgeriesCtrl.dispose();
    _admissionWeightCtrl.dispose();
    _todayWeightCtrl.dispose();
    _heightCtrl.dispose();
    _bmiCtrl.dispose();
    _admissionReasonCtrl.dispose();
    _medicalDiagnosisCtrl.dispose();
    _complicationsCtrl.dispose();
    _medicationsCtrl.dispose();
    _respTypeCtrl.dispose();
    _respRhythmCtrl.dispose();
    _respRateCtrl.dispose();
    _respPatternCtrl.dispose();
    _chestExcursionCtrl.dispose();
    _o2PercentCtrl.dispose();
    _o2FlowCtrl.dispose();
    _o2DeviceCtrl.dispose();
    _bronchialHygieneCtrl.dispose();
    _o2SatCtrl.dispose();
    _abgCtrl.dispose();
    _incentiveSpirometerCtrl.dispose();
    _mdiInhalerCtrl.dispose();
    _breathSoundsCtrl.dispose();
    _coughCtrl.dispose();
    _chestTubeCtrl.dispose();
    _pulseSeriesCtrl.dispose();
    _pulseRateCtrl.dispose();
    _pulseRhythmCtrl.dispose();
    _pulseAmplitudeCtrl.dispose();
    _heartSoundsCtrl.dispose();
    _bpSeriesCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    // Parse arrays
    final meds = _medicationsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final pulsesStr = _pulseSeriesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final pulses = pulsesStr.map((e) => int.tryParse(e) ?? 0).toList();

    final payload = {
      "id": widget.patientDisplayId,
      "department": _departmentCtrl.text,
      "admissionDate": _admissionDateCtrl.text,
      "bedNo": _bedNoCtrl.text,
      "allergiesText": _allergiesTextCtrl.text,
      "previousSurgeries": _previousSurgeriesCtrl.text,
      "admissionWeight": _admissionWeightCtrl.text,
      "todayWeight": _todayWeightCtrl.text,
      "height": _heightCtrl.text,
      "bmi": _bmiCtrl.text,
      "admissionReason": _admissionReasonCtrl.text,
      "medicalDiagnosis": _medicalDiagnosisCtrl.text,
      "complications": _complicationsCtrl.text,
      "medications": meds,
      "respType": _respTypeCtrl.text,
      "respRhythm": _respRhythmCtrl.text,
      "respRate": int.tryParse(_respRateCtrl.text) ?? 0,
      "respPattern": _respPatternCtrl.text,
      "chestExcursion": _chestExcursionCtrl.text,
      "o2Percent": int.tryParse(_o2PercentCtrl.text) ?? 0,
      "o2Flow": int.tryParse(_o2FlowCtrl.text) ?? 0,
      "o2Device": _o2DeviceCtrl.text,
      "bronchialHygiene": _bronchialHygieneCtrl.text,
      "o2Sat": int.tryParse(_o2SatCtrl.text) ?? 0,
      "abg": _abgCtrl.text,
      "incentiveSpirometer": _incentiveSpirometerCtrl.text,
      "mdiInhaler": _mdiInhalerCtrl.text,
      "breathSounds": _breathSoundsCtrl.text,
      "cough": _coughCtrl.text,
      "chestTube": _chestTubeCtrl.text,
      "pulseSeries": pulses,
      "pulseRate": int.tryParse(_pulseRateCtrl.text) ?? 0,
      "pulseRhythm": _pulseRhythmCtrl.text,
      "pulseAmplitude": _pulseAmplitudeCtrl.text,
      "heartSounds": _heartSoundsCtrl.text,
      "bpSeries": _bpSeriesCtrl.text,
      "map": _mapCtrl.text,
    };

    // Print payload for now, or connect to an API provider
    print(payload);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medical Record form saved!')),
    );
    Navigator.of(context).pop();
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Medical Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ResponsiveWrapper(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Patient Context Header
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patientName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Editing Record for ID: ${widget.patientDisplayId}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Overview
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Clinical Overview', style: Theme.of(context).textTheme.titleLarge),
                      const Divider(),
                      _buildTextField('Department', _departmentCtrl),
                      _buildTextField('Admission Date', _admissionDateCtrl, hint: 'YYYY-MM-DD'),
                      _buildTextField('Bed No', _bedNoCtrl),
                      _buildTextField('Allergies', _allergiesTextCtrl),
                      _buildTextField('Previous Surgeries', _previousSurgeriesCtrl),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Admission Weight', _admissionWeightCtrl)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildTextField('Today Weight', _todayWeightCtrl)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Height', _heightCtrl)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildTextField('BMI', _bmiCtrl)),
                        ],
                      ),
                      _buildTextField('Admission Reason', _admissionReasonCtrl),
                      _buildTextField('Medical Diagnosis', _medicalDiagnosisCtrl),
                      _buildTextField('Complications', _complicationsCtrl),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Medications
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Medications', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildTextField('Medications', _medicationsCtrl, hint: 'Comma separated (e.g. Aspirin 81mg, Bisoprolol 5mg)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Respiratory
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Respiratory System', style: Theme.of(context).textTheme.titleLarge),
                      const Divider(),
                      _buildTextField('Respiratory Type', _respTypeCtrl),
                      _buildTextField('Rhythm', _respRhythmCtrl),
                      _buildTextField('Rate', _respRateCtrl, keyboardType: TextInputType.number),
                      _buildTextField('Pattern', _respPatternCtrl),
                      _buildTextField('Chest Excursion', _chestExcursionCtrl),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('O2 %', _o2PercentCtrl, keyboardType: TextInputType.number)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildTextField('O2 Flow', _o2FlowCtrl, keyboardType: TextInputType.number)),
                        ],
                      ),
                      _buildTextField('O2 Device', _o2DeviceCtrl),
                      _buildTextField('Bronchial Hygiene', _bronchialHygieneCtrl),
                      _buildTextField('O2 Sat %', _o2SatCtrl, keyboardType: TextInputType.number),
                      _buildTextField('ABG', _abgCtrl),
                      _buildTextField('Incentive Spirometer', _incentiveSpirometerCtrl),
                      _buildTextField('MDI Inhaler', _mdiInhalerCtrl),
                      _buildTextField('Breath Sounds', _breathSoundsCtrl),
                      _buildTextField('Cough', _coughCtrl),
                      _buildTextField('Chest Tube', _chestTubeCtrl),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Cardio
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Cardiovascular System', style: Theme.of(context).textTheme.titleLarge),
                      const Divider(),
                      _buildTextField('Pulse Series', _pulseSeriesCtrl, hint: 'Comma separated ints (e.g. 78, 82, 80)'),
                      _buildTextField('Pulse Rate', _pulseRateCtrl, keyboardType: TextInputType.number),
                      _buildTextField('Pulse Rhythm', _pulseRhythmCtrl),
                      _buildTextField('Pulse Amplitude', _pulseAmplitudeCtrl),
                      _buildTextField('Heart Sounds', _heartSoundsCtrl),
                      _buildTextField('BP Series', _bpSeriesCtrl),
                      _buildTextField('MAP', _mapCtrl),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.check_circle),
                  label: const Text('Save Form Data', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}
