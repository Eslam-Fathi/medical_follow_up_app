import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';

class MedicalRecordScreen extends StatelessWidget {
  final UserDto user;
  final Map<String, dynamic> patientRecord;

  const MedicalRecordScreen({
    super.key,
    required this.user,
    required this.patientRecord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Record')),
      body: Center(
        child: ResponsiveWrapper(
          maxWidth: isDesktop ? 1100 : 700,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MAIN CARD CONTAINER
                Card(
                  elevation: 14,
                  shadowColor: colorScheme.shadow.withOpacity(0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 16),
                        _buildDemographicsCard(context),
                        const SizedBox(height: 16),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildRespiratoryCard(context)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildCardioCard(context)),
                            ],
                          )
                        else ...[
                          _buildRespiratoryCard(context),
                          const SizedBox(height: 16),
                          _buildCardioCard(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  String _val(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    return value.toString();
  }

  Widget _emptySection() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'N/A',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.name;
    final id = patientRecord['displayId'] ?? patientRecord['id'] ?? '—';

    String initialsFromName(String n) {
      final parts = n
          .trim()
          .split(' ')
          .where((p) => p.isNotEmpty)
          .take(2)
          .toList();
      if (parts.isEmpty) return '?';
      return parts.map((p) => p[0]).join().toUpperCase();
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            initialsFromName(name),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Patient ID: $id',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- DEMOGRAPHICS ----------------

  Widget _buildDemographicsCard(BuildContext context) {
    return _sectionCard(
      context,
      title: 'Patient Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _infoChip(
                context,
                'Department',
                _val(patientRecord['department']),
              ),
              _infoChip(context, 'Gender', _val(patientRecord['gender'])),
              _infoChip(context, 'Age', '${_val(patientRecord['age'])} yrs'),
              _infoChip(
                context,
                'Admission',
                _val(patientRecord['admissionDate']),
              ),
              _infoChip(context, 'Bed', _val(patientRecord['bedNo'])),
              _infoChip(context, 'Blood', _val(patientRecord['bloodType'])),
            ],
          ),
          const SizedBox(height: 12),
          _twoColRow(
            context,
            'Allergies',
            _val(patientRecord['allergiesText']),
          ),
          _twoColRow(
            context,
            'Surgeries',
            _val(patientRecord['previousSurgeries']),
          ),
          const SizedBox(height: 8),
          _twoColRow(
            context,
            'Adm. Weight',
            _val(patientRecord['admissionWeight']),
          ),
          _twoColRow(
            context,
            'Today Weight',
            _val(patientRecord['todayWeight']),
          ),
          _twoColRow(context, 'Height', _val(patientRecord['height'])),
          _twoColRow(context, 'BMI', _val(patientRecord['bmi'])),
          const SizedBox(height: 8),
          _twoColRow(context, 'Reason', _val(patientRecord['admissionReason'])),
          _twoColRow(
            context,
            'Diagnosis',
            _val(patientRecord['medicalDiagnosis']),
          ),
          _twoColRow(
            context,
            'Complications',
            _val(patientRecord['complications']),
          ),
        ],
      ),
    );
  }

  // ---------------- RESPIRATORY ----------------

  Widget _buildRespiratoryCard(BuildContext context) {
    final theme = Theme.of(context);

    // Check if the whole section is empty
    final isEmpty =
        patientRecord['respType'] == null &&
        patientRecord['respRate'] == null &&
        patientRecord['o2Sat'] == null;

    return _sectionCard(
      context,
      title: 'Respiratory System',
      child: isEmpty
          ? _emptySection()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(context, 'Type', _val(patientRecord['respType'])),
                    _infoChip(
                      context,
                      'Rate',
                      '${_val(patientRecord['respRate'])} /min',
                    ),
                    _infoChip(
                      context,
                      'O2 Sat',
                      '${_val(patientRecord['o2Sat'])} %',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'O₂ Therapy',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _twoColRow(context, 'Device', _val(patientRecord['o2Device'])),
                _twoColRow(
                  context,
                  'Percent/Flow',
                  '${_val(patientRecord['o2Percent'])}% / ${_val(patientRecord['o2Flow'])}L',
                ),
                const SizedBox(height: 8),
                _twoColRow(
                  context,
                  'Breath Sounds',
                  _val(patientRecord['breathSounds']),
                ),
                _twoColRow(context, 'Cough', _val(patientRecord['cough'])),
                _twoColRow(
                  context,
                  'Chest Tube',
                  _val(patientRecord['chestTube']),
                ),
              ],
            ),
    );
  }

  // ---------------- CARDIOVASCULAR ----------------

  Widget _buildCardioCard(BuildContext context) {
    final pulseSeries = (patientRecord['pulseSeries'] as List?) ?? const [];
    final isEmpty =
        pulseSeries.isEmpty &&
        patientRecord['pulseRate'] == null &&
        patientRecord['pulseRhythm'] == null;

    return _sectionCard(
      context,
      title: 'Cardiovascular System',
      child: isEmpty
          ? _emptySection()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pulseSeries.isNotEmpty) ...[
                  Text(
                    'Pulse Series (bpm)',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Wrap(
                    spacing: 6,
                    children: pulseSeries
                        .map<Widget>(
                          (p) => Chip(
                            label: Text('$p'),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                _twoColRow(
                  context,
                  'Current Rate',
                  '${_val(patientRecord['pulseRate'])} bpm',
                ),
                _twoColRow(
                  context,
                  'Rhythm',
                  _val(patientRecord['pulseRhythm']),
                ),
                _twoColRow(
                  context,
                  'Amplitude',
                  _val(patientRecord['pulseAmplitude']),
                ),
                _twoColRow(
                  context,
                  'Heart Sounds',
                  _val(patientRecord['heartSounds']),
                ),
                _twoColRow(
                  context,
                  'BP Series',
                  _val(patientRecord['bpSeries']),
                ),
                _twoColRow(context, 'MAP', _val(patientRecord['map'])),
              ],
            ),
    );
  }

  // ---------------- UI COMPONENTS ----------------

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Chip(
      label: Text('$label: $value', style: theme.textTheme.bodySmall),
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.6),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _twoColRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
