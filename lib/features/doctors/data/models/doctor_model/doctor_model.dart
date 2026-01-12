class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String rating;
  final String reviewCount;
  final String patientsCount;
  final String yearsExperience;
  final String aboutMe;
  final String imageUrl; // optional, for now we'll use avatar

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.patientsCount,
    required this.yearsExperience,
    required this.aboutMe,
    this.imageUrl = '',
  });
}
