/// Represents all supported medical specializations for doctors in the AuraMed system.
///
/// ### Why an enum?
/// Using an [enum] instead of plain [String]s for doctor specializations provides
/// several critical benefits:
///
/// 1. **Type safety** — It is impossible to accidentally create a typo like
///    `'Cardilogoy'`; the compiler enforces that only valid values are used.
/// 2. **Refactoring safety** — Renaming a specialization only requires changing
///    this one file. String literals scattered across the codebase would require
///    a risky find-and-replace.
/// 3. **Display names** — Each enum value carries a human-readable [displayName]
///    (e.g. `otolaryngology` → `"Otolaryngology (ENT)"`) that can be shown
///    directly in the UI without any mapping logic.
/// 4. **Serialization** — The [fromString] factory safely converts backend strings
///    into enum values, falling back to [generalPractice] if the value is unknown.
///
/// ### Backend representation
/// The backend stores specializations as their `name` string (the camelCase
/// enum identifier, e.g. `"cardiology"`). [fromString] handles the conversion
/// both from the enum `name` (camelCase) and from the `displayName` (title case).
///
/// ### Usage
/// ```dart
/// // In a form dropdown:
/// DropdownButton<DoctorSpecialization>(
///   value: selectedSpec,
///   items: DoctorSpecialization.values.map((s) =>
///     DropdownMenuItem(value: s, child: Text(s.displayName))
///   ).toList(),
/// )
///
/// // Parsing from API JSON:
/// final spec = DoctorSpecialization.fromString(json['specialization']);
/// ```
enum DoctorSpecialization {
  allergyAndImmunology('Allergy & Immunology'),
  anesthesiology('Anesthesiology'),
  cardiology('Cardiology'),
  dermatology('Dermatology'),
  emergencyMedicine('Emergency Medicine'),
  endocrinology('Endocrinology'),
  familyMedicine('Family Medicine'),
  gastroenterology('Gastroenterology'),
  generalPractice('General Practice'),
  geriatrics('Geriatrics'),
  gynecology('Gynecology'),
  hematology('Hematology'),
  infectiousDisease('Infectious Disease'),
  internalMedicine('Internal Medicine'),
  nephrology('Nephrology'),
  neurology('Neurology'),
  neurosurgery('Neurosurgery'),
  obstetrics('Obstetrics'),
  oncology('Oncology'),
  ophthalmology('Ophthalmology'),
  orthopedics('Orthopedics'),
  otolaryngology('Otolaryngology (ENT)'),
  pathology('Pathology'),
  pediatrics('Pediatrics'),
  physicalMedicineAndRehab('Physical Medicine & Rehab'),
  plasticSurgery('Plastic Surgery'),
  psychiatry('Psychiatry'),
  pulmonology('Pulmonology'),
  radiology('Radiology'),
  rheumatology('Rheumatology'),
  sportsMedicine('Sports Medicine'),
  surgery('Surgery'),
  urology('Urology'),
  vascularSurgery('Vascular Surgery');

  /// The human-readable label for this specialization, suitable for display in
  /// dropdown menus, doctor cards, and registration forms.
  final String displayName;

  /// Enum constructor — each value must provide a [displayName] string.
  const DoctorSpecialization(this.displayName);

  /// Converts a raw string (from the API or local storage) to a
  /// [DoctorSpecialization] enum value.
  ///
  /// Matching is case-insensitive and checks both the enum's internal [name]
  /// (e.g. `"cardiology"`) and its [displayName] (e.g. `"Cardiology"`).
  ///
  /// If no match is found, falls back to [DoctorSpecialization.generalPractice]
  /// rather than throwing an exception. This prevents the app from crashing if
  /// the backend adds a new specialization before the app is updated.
  static DoctorSpecialization fromString(String value) {
    return DoctorSpecialization.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == value.toLowerCase() ||
          e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => DoctorSpecialization.generalPractice,
    );
  }
}
