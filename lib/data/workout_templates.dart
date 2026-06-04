class WorkoutTemplate {
  final String title;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final int sets;
  final int reps;
  final String? weight;
  final String description;
  final bool isRestDay;

  const WorkoutTemplate({
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.sets = 3,
    this.reps = 10,
    this.weight,
    this.description = '',
    this.isRestDay = false,
  });

  static const WorkoutTemplate restDay = WorkoutTemplate(
    title: 'Rest Day (Istirahat)',
    category: 'Rest',
    durationMinutes: 0,
    caloriesBurned: 0,
    sets: 0,
    reps: 0,
    description: 'Hari ini adalah waktu untuk pemulihan otot. Perbanyak minum air, tidur cukup, dan konsumsi protein. Jika mau, lakukan peregangan ringan.',
    isRestDay: true,
  );
}

class WorkoutTemplatesData {
  // Map <Goal, Map<Weekday (1-7), List<WorkoutTemplate>>>
  static const Map<String, Map<int, List<WorkoutTemplate>>> programByGoal = {
    'Menurunkan Berat Badan': {
      1: [
        WorkoutTemplate(
          title: 'HIIT Cardio Pagi',
          category: 'Cardio',
          durationMinutes: 20,
          caloriesBurned: 300,
          sets: 4,
          reps: 1, // Berarti 1 sirkuit
          description: 'Lakukan jumping jacks, high knees, dan burpees dengan siklus 45 detik kerja, 15 detik istirahat.',
        ),
      ],
      2: [
        WorkoutTemplate(
          title: 'Full Body Circuit',
          category: 'Gym',
          durationMinutes: 30,
          caloriesBurned: 250,
          sets: 3,
          reps: 15,
          weight: 'Bodyweight',
          description: 'Squat, Push-up, Lunges, dan Plank. Lakukan berurutan tanpa jeda lama.',
        ),
      ],
      3: [
        WorkoutTemplate(
          title: 'Lari Santai (Jogging)',
          category: 'Running',
          durationMinutes: 30,
          caloriesBurned: 350,
          sets: 1,
          reps: 1,
          description: 'Lari dengan pace stabil. Pastikan detak jantung tetap berada di zona fat-burn (60-70% max HR).',
        ),
      ],
      4: [WorkoutTemplate.restDay],
      5: [
        WorkoutTemplate(
          title: 'Lompat Tali (Jump Rope)',
          category: 'Cardio',
          durationMinutes: 15,
          caloriesBurned: 200,
          sets: 5,
          reps: 100,
          description: 'Lakukan putaran cepat, 100 lompatan per set. Istirahat 30 detik antar set.',
        ),
      ],
      6: [
        WorkoutTemplate(
          title: 'Senam Aerobik / Zumba',
          category: 'Cardio',
          durationMinutes: 45,
          caloriesBurned: 400,
          sets: 1,
          reps: 1,
          description: 'Ikuti kelas aerobik atau video Zumba favorit Anda. Fokus pada pergerakan seluruh tubuh.',
        ),
      ],
      7: [WorkoutTemplate.restDay],
    },
    'Membangun Otot': {
      1: [
        WorkoutTemplate(
          title: 'Push Day (Dada, Bahu, Trisep)',
          category: 'Gym',
          durationMinutes: 45,
          caloriesBurned: 300,
          sets: 4,
          reps: 10,
          weight: 'Moderate - Heavy',
          description: 'Bench Press, Overhead Press, dan Tricep Pushdown. Fokus pada gerakan eksentrik lambat.',
        ),
      ],
      2: [
        WorkoutTemplate(
          title: 'Pull Day (Punggung, Bisep)',
          category: 'Gym',
          durationMinutes: 45,
          caloriesBurned: 300,
          sets: 4,
          reps: 10,
          weight: 'Moderate - Heavy',
          description: 'Pull-up, Barbell Row, dan Bicep Curl. Pastikan kontraksi otot maksimal.',
        ),
      ],
      3: [WorkoutTemplate.restDay],
      4: [
        WorkoutTemplate(
          title: 'Leg Day (Paha, Betis)',
          category: 'Gym',
          durationMinutes: 50,
          caloriesBurned: 400,
          sets: 4,
          reps: 12,
          weight: 'Heavy',
          description: 'Squat, Leg Press, Romanian Deadlift, dan Calf Raises. Jangan lupakan pemanasan!',
        ),
      ],
      5: [
        WorkoutTemplate(
          title: 'Upper Body (Hypertrophy)',
          category: 'Gym',
          durationMinutes: 45,
          caloriesBurned: 350,
          sets: 3,
          reps: 15,
          weight: 'Moderate',
          description: 'Latihan gabungan untuk otot bagian atas dengan repetisi lebih tinggi untuk memompa darah ke otot.',
        ),
      ],
      6: [
        WorkoutTemplate(
          title: 'Lower Body & Core',
          category: 'Gym',
          durationMinutes: 45,
          caloriesBurned: 350,
          sets: 3,
          reps: 15,
          weight: 'Moderate',
          description: 'Lunges, Leg Extension, Plank (3x60 detik), dan Crunch.',
        ),
      ],
      7: [WorkoutTemplate.restDay],
    },
    'Menjaga Kebugaran': {
      1: [
        WorkoutTemplate(
          title: 'Jalan Santai Sore',
          category: 'Walking',
          durationMinutes: 30,
          caloriesBurned: 150,
          sets: 1,
          reps: 1,
          description: 'Berjalan kaki keliling taman. Bagus untuk kesehatan kardiovaskular ringan dan mental.',
        ),
      ],
      2: [
        WorkoutTemplate(
          title: 'Senam Aerobik Ringan',
          category: 'Cardio',
          durationMinutes: 20,
          caloriesBurned: 180,
          sets: 1,
          reps: 1,
          description: 'Gerakan ringan untuk menjaga kelenturan dan pernapasan.',
        ),
      ],
      3: [WorkoutTemplate.restDay],
      4: [
        WorkoutTemplate(
          title: 'Berenang',
          category: 'Cardio',
          durationMinutes: 45,
          caloriesBurned: 400,
          sets: 1,
          reps: 1,
          description: 'Berenang dengan gaya bebas. Sangat baik untuk seluruh sendi karena rendah impact.',
        ),
      ],
      5: [WorkoutTemplate.restDay],
      6: [
        WorkoutTemplate(
          title: 'Bersepeda',
          category: 'Cardio',
          durationMinutes: 40,
          caloriesBurned: 300,
          sets: 1,
          reps: 1,
          description: 'Bersepeda santai di rute rata atau statis.',
        ),
      ],
      7: [WorkoutTemplate.restDay],
    },
    'Meningkatkan Kelenturan': {
      1: [
        WorkoutTemplate(
          title: 'Yoga Pagi (Hatha)',
          category: 'Yoga',
          durationMinutes: 30,
          caloriesBurned: 120,
          sets: 1,
          reps: 1,
          description: 'Fokus pada peregangan sendi dasar dan pernapasan dalam (pranayama).',
        ),
      ],
      2: [
        WorkoutTemplate(
          title: 'Peregangan Seluruh Tubuh',
          category: 'Stretching',
          durationMinutes: 15,
          caloriesBurned: 80,
          sets: 2,
          reps: 1,
          description: 'Tahan setiap gerakan peregangan selama 30-45 detik.',
        ),
      ],
      3: [WorkoutTemplate.restDay],
      4: [
        WorkoutTemplate(
          title: 'Pilates Dasar',
          category: 'Yoga',
          durationMinutes: 40,
          caloriesBurned: 200,
          sets: 1,
          reps: 1,
          description: 'Latihan untuk memperkuat inti (core) tubuh yang menunjang postur tegak.',
        ),
      ],
      5: [
        WorkoutTemplate(
          title: 'Dynamic Stretching',
          category: 'Stretching',
          durationMinutes: 20,
          caloriesBurned: 100,
          sets: 2,
          reps: 10,
          description: 'Gerakan dinamis seperti leg swings dan arm circles untuk mobilitas.',
        ),
      ],
      6: [WorkoutTemplate.restDay],
      7: [
        WorkoutTemplate(
          title: 'Yoga (Vinyasa Flow)',
          category: 'Yoga',
          durationMinutes: 45,
          caloriesBurned: 200,
          sets: 1,
          reps: 1,
          description: 'Transisi pose secara mengalir mengikuti tarikan dan hembusan napas.',
        ),
      ],
    },
  };

  /// Mendapatkan program latihan harian berdasarkan target pengguna dan hari dalam seminggu (1=Senin, 7=Minggu)
  static List<WorkoutTemplate> getProgramForDay(String? goal, int weekday) {
    String activeGoal = goal ?? 'Menjaga Kebugaran';
    if (!programByGoal.containsKey(activeGoal)) {
      activeGoal = 'Menjaga Kebugaran'; // Fallback
    }
    
    // Pastikan weekday selalu 1-7
    int dayIndex = weekday.clamp(1, 7);
    
    return programByGoal[activeGoal]?[dayIndex] ?? [WorkoutTemplate.restDay];
  }
}
