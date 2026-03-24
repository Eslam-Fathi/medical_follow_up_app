class DoctorModel {
  final String id;
  final String userId;
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
    required this.userId,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.patientsCount,
    required this.yearsExperience,
    required this.aboutMe,
    this.imageUrl = '',
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    var userMap = json['userId'];
    bool hasUserMap = userMap != null && userMap is Map;
    
    return DoctorModel(
      id: json['_id']?.toString() ?? '',
      userId: hasUserMap ? (userMap['_id']?.toString() ?? '') : '',
      name: hasUserMap ? (userMap['name']?.toString() ?? 'Unknown Doctor') : 'Unknown Doctor',
      specialty: json['specialization']?.toString() ?? 'Unknown',
      rating: json['rating']?.toString() ?? '4.8',
      reviewCount: json['reviewCount']?.toString() ?? '120+',
      patientsCount: json['patientsCount']?.toString() ?? '1k+',
      yearsExperience: (json['yearsOfExperience'] ?? 0).toString(),
      aboutMe: json['aboutMe']?.toString() ?? 'Dedicated practitioner committed to providing the highest quality of healthcare.',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}




// class DoctorDaySchedule {
//   final String day;
//   final String timeRange; // e.g. "09:00 - 13:00" or "Off"

//   DoctorDaySchedule({required this.day, required this.timeRange});
// }
