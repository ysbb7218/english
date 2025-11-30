class AppSettings {
  bool isDarkMode;
  String themeColor;
  int dailyGoal;
  bool showConfetti;
  String difficulty;
  int fontSize;

  AppSettings({
    this.isDarkMode = false,
    this.themeColor = 'indigo',
    this.dailyGoal = 10,
    this.showConfetti = true,
    this.difficulty = 'medium',
    this.fontSize = 16,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? themeColor,
    int? dailyGoal,
    bool? showConfetti,
    String? difficulty,
    int? fontSize,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeColor: themeColor ?? this.themeColor,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      showConfetti: showConfetti ?? this.showConfetti,
      difficulty: difficulty ?? this.difficulty,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
