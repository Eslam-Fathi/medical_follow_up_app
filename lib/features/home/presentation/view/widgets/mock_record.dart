import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


class MockPatientsLoader {
  static const _path = 'medical_record.json';

  Future<List<Map<String, dynamic>>> loadAll() async {
    final jsonStr = await rootBundle.loadString(_path);
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> loadFirst() async {
    final list = await loadAll();
    return list.first;
  }
}



class PatientRecord {
  final String id;
  final String name;
  final String? sex;
  final int? age;
  final String? department;
  final String? admissionDate;
  final String? bedNo;
  final String? bloodType;
  final String? admissionReason;
  final String? medicalDiagnosis;

  // add more fields as you need

  const PatientRecord({
    required this.id,
    required this.name,
    this.sex,
    this.age,
    this.department,
    this.admissionDate,
    this.bedNo,
    this.bloodType,
    this.admissionReason,
    this.medicalDiagnosis,
  });

  factory PatientRecord.fromJson(Map<String, dynamic> json) {
    return PatientRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      sex: json['sex'] as String?,
      age: json['age'] as int?,
      department: json['department'] as String?,
      admissionDate: json['admissionDate'] as String?,
      bedNo: json['bedNo'] as String?,
      bloodType: json['bloodType'] as String?,
      admissionReason: json['admissionReason'] as String?,
      medicalDiagnosis: json['medicalDiagnosis'] as String?,
    );
  }
}


// lib/features/medical_record/data/mock_patient.dart

const Map<String, dynamic> kMockPatientRecord = {
  "id": "P-0001",
  "name": "Ahmed Youssef",
  "sex": "Male",
  "age": 54,
  "department": "Cardiology",
  "admissionDate": "2026-03-01",
  "bedNo": "C-12",
  "bloodType": "A+",
  "allergiesText": "Penicillin (rash), Peanuts (anaphylaxis)",
  "previousSurgeries": "CABG x3 (2018)",
  "admissionWeight": "88 kg",
  "todayWeight": "87.2 kg",
  "height": "176 cm",
  "bmi": "28.1",
  "admissionReason": "Chest pain on exertion, shortness of breath",
  "medicalDiagnosis": "Ischemic heart disease, stable angina",
  "complications": "None documented",
  "conditions": [
    "Hypertension",
    "Hyperlipidemia",
    "Ischemic heart disease"
  ],
  "medications": [
    "Aspirin 81 mg OD",
    "Atorvastatin 40 mg HS",
    "Bisoprolol 5 mg OD",
    "Isosorbide dinitrate 20 mg TID"
  ],
  "allergies": [
    "Penicillin",
    "Peanuts"
  ],
  "respType": "Spontaneous",
  "respRhythm": "Regular",
  "respRate": 18,
  "respPattern": "Eupnea",
  "chestExcursion": "Symmetrical",
  "o2Percent": 28,
  "o2Flow": 2,
  "o2Device": "Nasal cannula",
  "bronchialHygiene": "Cough and deep breathing q2h",
  "o2Sat": 96,
  "abg": "PaO2 82 mmHg / pH 7.40 / PaCO2 38 mmHg / HCO3 24",
  "incentiveSpirometer": "Used q4h",
  "mdiInhaler": "None",
  "breathSounds": "Clear bilaterally",
  "cough": "Occasional dry cough",
  "chestTube": "None",
  "pulseSeries": [78, 82, 80],
  "pulseRate": 80,
  "pulseRhythm": "Regular",
  "pulseAmplitude": "+2 normal",
  "heartSounds": "S1 S2 normal, no murmur",
  "bpSeries": "130/80, 128/78, 126/76",
  "map": "95 mmHg"
};
