import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/utils/responsive.dart';
import 'package:medical_follow_up_app/core/utils/responsive_wrapper.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:medical_follow_up_app/features/medical_record/data/api/medical_record_api.dart';

/// View of a single patient's medical record connected to backend persistence.
class MedicalRecordScreen extends ConsumerWidget {
  final UserDto user;
  final Map<String, dynamic> patientRecord;

  const MedicalRecordScreen({
    super.key,
    required this.user,
    required this.patientRecord,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = Responsive.isDesktop(context);

    // Prefer patient document _id (from patient profile object).
    // patientRecord['_id']        → comes from the /api/patients list (patient doc ID ✔)
    // patientRecord['id']         → alias sometimes present
    // patientRecord['patientId']  → nested reference
    // user.id                     → last resort (user auth ID, may not work with API)
    final patientId = patientRecord['_id']?.toString() ??
        patientRecord['id']?.toString() ??
        patientRecord['patientId']?.toString() ??
        user.id;

    final asyncRecord = ref.watch(patientRecordProvider(patientId));

    // Show error in a SnackBar if the fetch fails (don't silently fail).
    ref.listen<AsyncValue<Map<String, dynamic>>>(patientRecordProvider(patientId),
        (_, next) {
      if (next is AsyncError) {
        final msg = next.error.toString();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not load record: $msg'),
              backgroundColor: colorScheme.error,
            ),
          );
        });
      }
    });

    final asyncData = asyncRecord.value ?? {};

    // The backend returns demographics (age, gender, bloodType, etc.) nested
    // inside the medical record's `patientId` object. Promote them to top-level
    // so the UI can render them without knowing the nesting structure.
    final nestedPatient = asyncData['patientId'];
    final patientDemographics = nestedPatient is Map
        ? Map<String, dynamic>.from(nestedPatient as Map)
        : <String, dynamic>{};

    // Layer priority (highest wins):
    // 1. asyncData (the actual medical record fields like department, respRate…)
    // 2. patientRecord passed via navigation (may already have age/gender from profile)
    // 3. patientDemographics extracted from nested patientId (lowest priority)
    final mergedRecord = <String, dynamic>{
      ...patientDemographics,  // age, gender, bloodType from nested object
      ...patientRecord,         // profile-page data overrides if present
      ...asyncData,             // medical record data is highest priority
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Record')),
      body: asyncRecord.isLoading && mergedRecord.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ResponsiveWrapper(
                maxWidth: isDesktop ? 1100 : 700,
                backgroundColor: Colors.transparent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 14,
                        shadowColor: colorScheme.shadow.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(context, mergedRecord),
                              const SizedBox(height: 16),
                              _buildDemographicsCard(context, mergedRecord),
                              const SizedBox(height: 16),
                              if (isDesktop)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildRespiratoryCard(
                                          context, mergedRecord),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildCardioCard(
                                          context, mergedRecord),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildRespiratoryCard(context, mergedRecord),
                                const SizedBox(height: 16),
                                _buildCardioCard(context, mergedRecord),
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

  String _val(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    return value.toString();
  }

  /// Parses an ISO-8601 date string (e.g. "2026-05-05T00:00:00.000Z") and
  /// returns a human-readable string like "05 May 2026".
  /// Falls back to [_val] if the value is null, empty, or not parseable.
  String _fmtDate(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    try {
      final dt = DateTime.parse(value.toString()).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day.toString().padLeft(2, '0')} '
          '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return _val(value); // not a parseable date, show as-is
    }
  }

  String _formatMeds(dynamic meds) {
    if (meds == null) return '—';
    if (meds is List) {
      if (meds.isEmpty) return '—';
      return meds.map((m) {
        if (m is Map) {
          final name = m['name']?.toString() ?? '';
          final dose = m['dose']?.toString() ?? '';
          return '$name $dose'.trim();
        }
        return m.toString();
      }).where((s) => s.isNotEmpty).join(', ');
    }
    return meds.toString();
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

  Widget _buildHeader(BuildContext context, Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final name = user.name;
    final id = record['displayId'] ?? record['id'] ?? '—';

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

  Widget _buildDemographicsCard(
      BuildContext context, Map<String, dynamic> record) {
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
              _infoChip(context, 'Department', _val(record['department'])),
              _infoChip(context, 'Gender', _val(record['gender'])),
              _infoChip(context, 'Age', '${_val(record['age'])} yrs'),
              _infoChip(context, 'Admission', _fmtDate(record['admissionDate'])),
              _infoChip(context, 'Bed', _val(record['bedNo'])),
              _infoChip(context, 'Blood', _val(record['bloodType'])),
            ],
          ),
          const SizedBox(height: 12),
          _twoColRow(context, 'Allergies', _val(record['allergiesText'])),
          _twoColRow(context, 'Surgeries', _val(record['previousSurgeries'])),
          const SizedBox(height: 8),
          _twoColRow(context, 'Adm. Weight', _val(record['admissionWeight'])),
          _twoColRow(context, 'Today Weight', _val(record['todayWeight'])),
          _twoColRow(context, 'Height', _val(record['height'])),
          _twoColRow(context, 'BMI', _val(record['bmi'])),
          const SizedBox(height: 8),
          _twoColRow(context, 'Reason', _val(record['admissionReason'])),
          _twoColRow(context, 'Diagnosis', _val(record['medicalDiagnosis'])),
          _twoColRow(context, 'Complications', _val(record['complications'])),
          _twoColRow(context, 'Medications', _formatMeds(record['medications'])),
        ],
      ),
    );
  }

  Widget _buildRespiratoryCard(
      BuildContext context, Map<String, dynamic> record) {
    final theme = Theme.of(context);

    final isEmpty = record['respType'] == null &&
        record['respRate'] == null &&
        record['o2Sat'] == null;

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
                    _infoChip(context, 'Type', _val(record['respType'])),
                    _infoChip(
                      context,
                      'Rate',
                      '${_val(record['respRate'])} /min',
                    ),
                    _infoChip(
                      context,
                      'O2 Sat',
                      '${_val(record['o2Sat'])} %',
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
                _twoColRow(context, 'Device', _val(record['o2Device'])),
                _twoColRow(
                  context,
                  'Percent/Flow',
                  '${_val(record['o2Percent'])}% / ${_val(record['o2Flow'])}L',
                ),
                const SizedBox(height: 8),
                _twoColRow(
                  context,
                  'Breath Sounds',
                  _val(record['breathSounds']),
                ),
                _twoColRow(context, 'Cough', _val(record['cough'])),
                _twoColRow(
                  context,
                  'Chest Tube',
                  _val(record['chestTube']),
                ),
              ],
            ),
    );
  }

  Widget _buildCardioCard(BuildContext context, Map<String, dynamic> record) {
    final pulseSeries = (record['pulseSeries'] as List?) ?? const [];
    final isEmpty = pulseSeries.isEmpty &&
        record['pulseRate'] == null &&
        record['pulseRhythm'] == null;

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
                  '${_val(record['pulseRate'])} bpm',
                ),
                _twoColRow(context, 'Rhythm', _val(record['pulseRhythm'])),
                _twoColRow(
                  context,
                  'Amplitude',
                  _val(record['pulseAmplitude']),
                ),
                _twoColRow(
                  context,
                  'Heart Sounds',
                  _val(record['heartSounds']),
                ),
                _twoColRow(context, 'BP Series', _val(record['bpSeries'])),
                _twoColRow(context, 'MAP', _val(record['map'])),
              ],
            ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
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
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
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
