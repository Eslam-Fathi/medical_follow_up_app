import 'package:flutter/material.dart';
import 'package:medical_follow_up_app/core/theme/dark_theme_data.dart';
import 'package:medical_follow_up_app/core/theme/light_theme_data.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/home_screen.dart';


void main() {
  runApp(const MedME());
}

class MedME extends StatelessWidget {
  const MedME({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedME',
      theme: healtecLightTheme,
      // darkTheme: appDarkTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Follow-up'),
      ),
      body: HomeFollowUpScreen(),
    );
  }
}