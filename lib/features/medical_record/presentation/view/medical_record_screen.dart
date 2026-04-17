import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';

class MedicalRecordScreen extends StatelessWidget {
  final Map<String, dynamic> patientRecord;

  const MedicalRecordScreen({
    super.key,
    required this.patientRecord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical record'),
      ),
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

  // ---------------- HEADER ----------------

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final name = patientRecord['name'] ?? 'Unknown patient';
    final id = patientRecord['id'] ?? '—';

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
          child: Text(
            initialsFromName(name.toString()),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.toString(),
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

  // ---------------- DEMOGRAPHICS / PAGE 1 ----------------
  // Patient’s name, department, sex, age, admission date, allergies, surgeries,
  // admission weight, today’s weight, height, BMI, reason for admission, diagnosis.[page:293]

  Widget _buildDemographicsCard(BuildContext context) {
    final theme = Theme.of(context);

    return _sectionCard(
      context,
      title: 'Patient overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _infoChip(context, 'Department',
                  '${patientRecord['department'] ?? '—'}'),
              _infoChip(context, 'Sex', '${patientRecord['sex'] ?? '—'}'),
              _infoChip(context, 'Age', '${patientRecord['age'] ?? '—'}'),
              _infoChip(context, 'Admission date',
                  '${patientRecord['admissionDate'] ?? '—'}'),
              _infoChip(context, 'Bed no',
                  '${patientRecord['bedNo'] ?? '—'}'),
              _infoChip(context, 'Blood type',
                  '${patientRecord['bloodType'] ?? '—'}'),
            ],
          ),
          const SizedBox(height: 12),
          _twoColRow(
            context,
            'Allergies',
            patientRecord['allergiesText'] ?? 'None reported',
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'Previous surgeries',
            patientRecord['previousSurgeries'] ??
                'None / not documented',
          ),
          const SizedBox(height: 8),
          _twoColRow(
            context,
            'Admission weight',
            patientRecord['admissionWeight'] ?? '—',
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'Today’s weight',
            patientRecord['todayWeight'] ?? '—',
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'Height',
            patientRecord['height'] ?? '—',
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'BMI',
            patientRecord['bmi'] ?? '—',
          ),
          const SizedBox(height: 8),
          _twoColRow(
            context,
            'Reason for admission',
            patientRecord['admissionReason'] ??
                'Not documented (patient’s own words).',
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'Medical diagnosis',
            patientRecord['medicalDiagnosis'] ?? 'Not documented',
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'Unexpected events / complications',
            patientRecord['complications'] ?? 'None documented',
          ),
        ],
      ),
    );
  }

  // ---------------- RESPIRATORY / PAGE 1–2 ----------------
  // Type, rhythm, rate, pattern (Kussmaul, Cheyne-Stokes,…), chest excursion,
  // O2 therapy (percent, L/min, device), broncho-pulmonary hygiene,
  // monitoring, breath sounds, cough, secretions, chest tube.[page:293]

  Widget _buildRespiratoryCard(BuildContext context) {
    final theme = Theme.of(context);

    return _sectionCard(
      context,
      title: 'Respiratory system',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(context, 'Type',
                  '${patientRecord['respType'] ?? 'Spontaneous / Artificial'}'),
              _infoChip(context, 'Rhythm',
                  '${patientRecord['respRhythm'] ?? 'Regular / Irregular'}'),
              _infoChip(context, 'Rate',
                  '${patientRecord['respRate'] ?? '—'} /min'),
              _infoChip(context, 'Pattern',
                  '${patientRecord['respPattern'] ?? '—'}'),
              _infoChip(context, 'Chest excursion',
                  '${patientRecord['chestExcursion'] ?? 'Symmetrical / Asymmetrical / Retractions'}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'O₂ therapy',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'O₂ percent',
            patientRecord['o2Percent'] != null
                ? '${patientRecord['o2Percent']} %'
                : '—',
          ),
          _twoColRow(
            context,
            'Flow',
            patientRecord['o2Flow'] != null
                ? '${patientRecord['o2Flow']} L/min'
                : '—',
          ),
          _twoColRow(
            context,
            'Device',
            patientRecord['o2Device'] ?? '—',
          ),
          const SizedBox(height: 8),
          Text(
            'Broncho‑pulmonary hygiene',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'Techniques',
            patientRecord['bronchialHygiene'] ??
                'Postural drainage, percussion/vibration, coughing, suctioning',
          ),
          const SizedBox(height: 8),
          Text(
            'Respiratory monitoring',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          _twoColRow(
            context,
            'O₂ saturation',
            patientRecord['o2Sat'] != null
                ? '${patientRecord['o2Sat']} %'
                : '—',
          ),
          _twoColRow(
            context,
            'ABG (PaO₂ / pH / PaCO₂ / HCO₃)',
            patientRecord['abg'] ?? 'Not available',
          ),
          _twoColRow(
            context,
            'Incentive spirometer',
            patientRecord['incentiveSpirometer'] ??
                'Not used / q__ hrs',
          ),
          _twoColRow(
            context,
            'MDI inhaler',
            patientRecord['mdiInhaler'] ?? 'None / albuterol / atrovent',
          ),
          const SizedBox(height: 8),
          _twoColRow(
            context,
            'Breath sounds',
            patientRecord['breathSounds'] ??
                'Clear / wheezes / rhonchi / crackles / friction rubs',
          ),
          _twoColRow(
            context,
            'Cough',
            patientRecord['cough'] ??
                'Dry / productive / none (amount, color)',
          ),
          _twoColRow(
            context,
            'Chest tube',
            patientRecord['chestTube'] ?? 'None',
          ),
        ],
      ),
    );
  }

  // ---------------- CARDIOVASCULAR / PAGE 2–3 ----------------
  // Pulse rate (serial), rhythm, amplitude, heart sounds, BP/ MAP.[page:293]

  Widget _buildCardioCard(BuildContext context) {
    final theme = Theme.of(context);

    final pulseSeries =
        (patientRecord['pulseSeries'] as List?) ?? const []; // e.g. [80,82,78]

    return _sectionCard(
      context,
      title: 'Cardiovascular system',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pulseSeries.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pulse rate / hour (bpm)',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: pulseSeries
                      .map<Widget>((p) => Chip(
                            label: Text('$p'),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],
            )
          else
            _twoColRow(
              context,
              'Pulse rate',
              patientRecord['pulseRate'] != null
                  ? '${patientRecord['pulseRate']} bpm'
                  : 'Not recorded',
            ),
          _twoColRow(
            context,
            'Rhythm',
            patientRecord['pulseRhythm'] ??
                'Regular / irregular / other',
          ),
          _twoColRow(
            context,
            'Pulse amplitude',
            patientRecord['pulseAmplitude'] ??
                '+4 bounding / +3 full / +2 normal / +1 weak / 0 absent',
          ),
          const SizedBox(height: 8),
          _twoColRow(
            context,
            'Heart sounds',
            patientRecord['heartSounds'] ??
                'Normal / murmur / friction rub',
          ),
          const SizedBox(height: 8),
          _twoColRow(
            context,
            'BP measurements / hour',
            patientRecord['bpSeries'] ??
                '— / serial values not entered',
          ),
          _twoColRow(
            context,
            'MAP',
            patientRecord['map'] ?? '—',
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 4,
      shadowColor: colorScheme.shadow.withOpacity(0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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
      backgroundColor:
          theme.colorScheme.surfaceVariant.withOpacity(0.6),
    );
  }

  Widget _twoColRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
