class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji for simplicity
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementBadge copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementBadge(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
