import 'package:flutter_riverpod/flutter_riverpod.dart';

class Workout {
  final String name;
  final String category;
  final int sets;
  final int reps;
  final DateTime createdAt;

  Workout({
    required this.name,
    required this.category,
    required this.sets,
    required this.reps,
    required this.createdAt,
  });
}

final workoutProvider = FutureProvider<List<Workout>>((ref) async {
  return [
    Workout(
      name: 'Push Up',
      category: 'Chest',
      sets: 3,
      reps: 15,
      createdAt: DateTime.now(),
    ),
    Workout(
      name: 'Squat',
      category: 'Leg',
      sets: 4,
      reps: 12,
      createdAt: DateTime.now(),
    ),
  ];
});