import 'package:flutter/material.dart';

void main() {
  runApp(const MedME());
}

class MedME extends StatelessWidget {
  const MedME({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedME',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
      body: const Center(
        child: Text('Welcome to MedME'),
      ),
    );
  }
}