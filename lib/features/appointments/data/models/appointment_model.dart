class AppointmentUserRef {
  final String id;
  final String name;
  final String email;

  AppointmentUserRef({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AppointmentUserRef.fromJson(Map<String, dynamic> json) {
    return AppointmentUserRef(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class AppointmentPatientRef {
  final String id;
  final AppointmentUserRef user;

  AppointmentPatientRef({
    required this.id,
    required this.user,
  });

  factory AppointmentPatientRef.fromJson(Map<String, dynamic> json) {
    return AppointmentPatientRef(
      id: json['_id'] as String,
      user: AppointmentUserRef.fromJson(
        json['userId'] as Map<String, dynamic>,
      ),
    );
  }
}

class AppointmentDoctorRef {
  final String id;
  final AppointmentUserRef user;
  final String specialization;

  AppointmentDoctorRef({
    required this.id,
    required this.user,
    required this.specialization,
  });

  factory AppointmentDoctorRef.fromJson(Map<String, dynamic> json) {
    return AppointmentDoctorRef(
      id: json['_id'] as String,
      user: AppointmentUserRef.fromJson(
        json['userId'] as Map<String, dynamic>,
      ),
      specialization: json['specialization'] as String,
    );
  }
}

class Appointment {
  final String id;
  final AppointmentPatientRef patient;
  final AppointmentDoctorRef doctor;
  final DateTime date;
  final String status; // PENDING / CONFIRMED / CANCELLED / COMPLETED

  Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.date,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] as String,
      patient: AppointmentPatientRef.fromJson(
        json['patientId'] as Map<String, dynamic>,
      ),
      doctor: AppointmentDoctorRef.fromJson(
        json['doctorId'] as Map<String, dynamic>,
      ),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
    );
  }
}
