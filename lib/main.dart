import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medical_follow_up_app/core/theme/light_theme_data.dart';
import 'package:medical_follow_up_app/core/utils/scroll_bar_behavior.dart';
import 'package:medical_follow_up_app/features/auth/presentation/view/auth_switcher.dart';
import 'package:medical_follow_up_app/features/home/presentation/view/home_screen.dart';
import 'package:medical_follow_up_app/features/profile/presentation/view/profile_screen.dart';


void main() {
  runApp(const ProviderScope(child: MedME()));
}


class MedME extends StatelessWidget {
  const MedME({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: NoScrollbarScrollBehavior(),
      title: 'MedME',
      theme: healtecLightTheme,
      debugShowCheckedModeBanner: false,
      // darkTheme: appDarkTheme,
      home: const StartPoint(),
      routes: {
        '/auth': (_) => const AuthSwitcher(),
        '/home': (_) => const HomeFollowUpScreen(),
        '/profile': (_) => const ProfileScreen(), 
      },
    );
  }
}

class StartPoint extends StatelessWidget {
  const StartPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: const AuthSwitcher(),
    );
  }
}