class UserStats {
  int totalStudied;
  int totalCorrect;
  int totalWrong;
  int currentStreak;
  int longestStreak;
  DateTime lastStudyDate;
  Map<DateTime, int> dailyProgress;

  UserStats({
    this.totalStudied = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastStudyDate,
    Map<DateTime, int>? dailyProgress,
  }) : lastStudyDate = lastStudyDate ?? DateTime(2000),
       dailyProgress = dailyProgress ?? {};

  double get successRate {
    if (totalCorrect + totalWrong == 0) return 0.0;
    return totalCorrect / (totalCorrect + totalWrong);
  }

  int get todayStudied {
    final today = DateTime.now();
    return dailyProgress[today] ?? 0;
  }

  void updateDailyProgress(int studiedToday) {
    final today = DateTime.now();
    dailyProgress[today] = studiedToday;

    // Streak hesaplama
    final yesterday = today.subtract(Duration(days: 1));
    if (dailyProgress.containsKey(yesterday) ||
        lastStudyDate.isBefore(yesterday)) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    lastStudyDate = today;
    totalStudied += studiedToday;
  }

  void updateQuizStats(int correct, int wrong) {
    totalCorrect += correct;
    totalWrong += wrong;
  }
}
