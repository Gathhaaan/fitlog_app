import 'package:flutter/material.dart';

class AddWorkoutScreen extends StatelessWidget {
  const AddWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Workout')),
      body: const Center(
        child: Text('Tambah Workout'),
      ),
    );
  }
}