import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';
import 'package:medical_follow_up_app/features/medical_record/data/api/medical_record_api.dart';

/// Form screen used by clinicians to create/update a patient's
/// detailed medical record.
class MedicalRecordFormScreen extends ConsumerStatefulWidget {
  final String patientDisplayId;
  final String patientName;

  const MedicalRecordFormScreen({
    super.key,
    required this.patientDisplayId,
    required this.patientName,
  });

  @override
  ConsumerState<MedicalRecordFormScreen> createState() =>
      _MedicalRecordFormScreenState();
}

class _MedicalRecordFormScreenState
    extends ConsumerState<MedicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ---------------- CONTROLLERS ----------------
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

  // Medications (comma separated)
  final _medicationsCtrl = TextEditingController();

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
  final _pulseSeriesCtrl = TextEditingController();
  final _pulseRateCtrl = TextEditingController();
  final _pulseRhythmCtrl = TextEditingController();
  final _pulseAmplitudeCtrl = TextEditingController();
  final _heartSoundsCtrl = TextEditingController();
  final _bpSeriesCtrl = TextEditingController();
  final _mapCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingRecord();
  }

  Future<void> _loadExistingRecord() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(medicalRecordApiProvider);
      final data =
          await api.getMedicalRecordByPatientId(widget.patientDisplayId);
      if (data.isNotEmpty && mounted) {
        setState(() {
          _departmentCtrl.text = _str(data['department']);
          _admissionDateCtrl.text = _str(data['admissionDate']);
          _bedNoCtrl.text = _str(data['bedNo']);
          _allergiesTextCtrl.text = _str(data['allergiesText']);
          _previousSurgeriesCtrl.text = _str(data['previousSurgeries']);
          _admissionWeightCtrl.text = _str(data['admissionWeight']);
          _todayWeightCtrl.text = _str(data['todayWeight']);
          _heightCtrl.text = _str(data['height']);
          _bmiCtrl.text = _str(data['bmi']);
          _admissionReasonCtrl.text = _str(data['admissionReason']);
          _medicalDiagnosisCtrl.text = _str(data['medicalDiagnosis']);
          _complicationsCtrl.text = _str(data['complications']);

          if (data['medications'] is List) {
            final medsList = data['medications'] as List;
            _medicationsCtrl.text = medsList.map((m) {
              if (m is Map) {
                return '${m['name'] ?? ''} ${m['dose'] ?? ''}'.trim();
              }
              return m.toString();
            }).where((s) => s.isNotEmpty).join(', ');
          } else if (data['medications'] != null) {
            _medicationsCtrl.text = data['medications'].toString();
          }

          _respTypeCtrl.text = _str(data['respType']);
          _respRhythmCtrl.text = _str(data['respRhythm']);
          _respRateCtrl.text = _str(data['respRate']);
          _respPatternCtrl.text = _str(data['respPattern']);
          _chestExcursionCtrl.text = _str(data['chestExcursion']);
          _o2PercentCtrl.text = _str(data['o2Percent']);
          _o2FlowCtrl.text = _str(data['o2Flow']);
          _o2DeviceCtrl.text = _str(data['o2Device']);
          _bronchialHygieneCtrl.text = _str(data['bronchialHygiene']);
          _o2SatCtrl.text = _str(data['o2Sat']);
          _abgCtrl.text = _str(data['abg']);
          _incentiveSpirometerCtrl.text = _str(data['incentiveSpirometer']);
          _mdiInhalerCtrl.text = _str(data['mdiInhaler']);
          _breathSoundsCtrl.text = _str(data['breathSounds']);
          _coughCtrl.text = _str(data['cough']);
          _chestTubeCtrl.text = _str(data['chestTube']);

          if (data['pulseSeries'] is List) {
            _pulseSeriesCtrl.text = (data['pulseSeries'] as List).join(', ');
          } else if (data['pulseSeries'] != null) {
            _pulseSeriesCtrl.text = data['pulseSeries'].toString();
          }

          _pulseRateCtrl.text = _str(data['pulseRate']);
          _pulseRhythmCtrl.text = _str(data['pulseRhythm']);
          _pulseAmplitudeCtrl.text = _str(data['pulseAmplitude']);
          _heartSoundsCtrl.text = _str(data['heartSounds']);
          _bpSeriesCtrl.text = _str(data['bpSeries']);
          _mapCtrl.text = _str(data['map']);
        });
      }
    } catch (_) {
      // Ignore if no prior record exists or load fails
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _str(dynamic val) {
    if (val == null || val.toString() == 'null' || val.toString() == '—') {
      return '';
    }
    return val.toString();
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final meds = _medicationsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final pulsesStr = _pulseSeriesCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
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

      final api = ref.read(medicalRecordApiProvider);
      await api.saveMedicalRecord(payload);

      // Invalidate provider so updated data is loaded across all screens
      ref.invalidate(patientRecordProvider(widget.patientDisplayId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical Record form saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
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
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isLoading ? null : _submit,
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
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.patientName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
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

                  // 1. Clinical Overview section.
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Clinical Overview',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          _buildTextField('Department', _departmentCtrl),
                          _buildTextField(
                            'Admission Date',
                            _admissionDateCtrl,
                            hint: 'YYYY-MM-DD',
                          ),
                          _buildTextField('Bed No', _bedNoCtrl),
                          _buildTextField('Allergies', _allergiesTextCtrl),
                          _buildTextField(
                            'Previous Surgeries',
                            _previousSurgeriesCtrl,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Admission Weight',
                                  _admissionWeightCtrl,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTextField(
                                  'Today Weight',
                                  _todayWeightCtrl,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField('Height', _heightCtrl),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: _buildTextField('BMI', _bmiCtrl)),
                            ],
                          ),
                          _buildTextField(
                            'Admission Reason',
                            _admissionReasonCtrl,
                          ),
                          _buildTextField(
                            'Medical Diagnosis',
                            _medicalDiagnosisCtrl,
                          ),
                          _buildTextField('Complications', _complicationsCtrl),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Medications section.
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Medications',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            'Medications',
                            _medicationsCtrl,
                            hint:
                                'Comma separated (e.g. Aspirin 81mg, Bisoprolol 5mg)',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Respiratory section.
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Respiratory System',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          _buildTextField('Respiratory Type', _respTypeCtrl),
                          _buildTextField('Rhythm', _respRhythmCtrl),
                          _buildTextField(
                            'Rate',
                            _respRateCtrl,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField('Pattern', _respPatternCtrl),
                          _buildTextField(
                            'Chest Excursion',
                            _chestExcursionCtrl,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'O2 %',
                                  _o2PercentCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTextField(
                                  'O2 Flow',
                                  _o2FlowCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          _buildTextField('O2 Device', _o2DeviceCtrl),
                          _buildTextField(
                            'Bronchial Hygiene',
                            _bronchialHygieneCtrl,
                          ),
                          _buildTextField(
                            'O2 Sat %',
                            _o2SatCtrl,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField('ABG', _abgCtrl),
                          _buildTextField(
                            'Incentive Spirometer',
                            _incentiveSpirometerCtrl,
                          ),
                          _buildTextField('MDI Inhaler', _mdiInhalerCtrl),
                          _buildTextField('Breath Sounds', _breathSoundsCtrl),
                          _buildTextField('Cough', _coughCtrl),
                          _buildTextField('Chest Tube', _chestTubeCtrl),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Cardiovascular section.
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Cardiovascular System',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          _buildTextField(
                            'Pulse Series',
                            _pulseSeriesCtrl,
                            hint: 'Comma separated ints (e.g. 78, 82, 80)',
                          ),
                          _buildTextField(
                            'Pulse Rate',
                            _pulseRateCtrl,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField('Pulse Rhythm', _pulseRhythmCtrl),
                          _buildTextField(
                            'Pulse Amplitude',
                            _pulseAmplitudeCtrl,
                          ),
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
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(
                        _isLoading ? 'Saving...' : 'Save Form Data',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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
