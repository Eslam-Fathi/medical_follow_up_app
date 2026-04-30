import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:medical_follow_up_app/features/doctors/data/models/doctor_model/doctor_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final careTeamProvider =
    StateNotifierProvider<CareTeamNotifier, List<DoctorModel>>((ref) {
      return CareTeamNotifier();
    });

class CareTeamNotifier extends StateNotifier<List<DoctorModel>> {
  CareTeamNotifier() : super([]) {
    _loadFromPrefs();
  }

  static const _prefKey = 'saved_care_team';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefKey) ?? [];
    try {
      final doctors = jsonList
          .map(
            (item) =>
                DoctorModel.fromJson(jsonDecode(item) as Map<String, dynamic>),
          )
          .toList();
      state = doctors;
    } catch (e) {
      // In case of parsing error
      state = [];
    }
  }

  Future<void> addDoctor(DoctorModel doctor) async {
    // avoid duplicates
    if (state.any((d) => d.id == doctor.id)) return;

    state = [...state, doctor];
    _saveToPrefs();
  }

  Future<void> removeDoctor(String id) async {
    state = state.where((d) => d.id != id).toList();
    _saveToPrefs();
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_prefKey, jsonList);
  }
}
