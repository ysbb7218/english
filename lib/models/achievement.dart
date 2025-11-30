class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  bool isUnlocked;
  DateTime? unlockedAt;
  final int target;
  int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.target,
    this.currentProgress = 0,
  });

  double get progress => target > 0 ? currentProgress / target : 0.0;

  void updateProgress(int newProgress) {
    currentProgress = newProgress;
    if (currentProgress >= target && !isUnlocked) {
      isUnlocked = true;
      unlockedAt = DateTime.now();
    }
  }
}
