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

  final String displayName;
  const DoctorSpecialization(this.displayName);

  static DoctorSpecialization fromString(String value) {
    return DoctorSpecialization.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => DoctorSpecialization.generalPractice,
    );
  }
}
