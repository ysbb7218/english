class Word {
  final String english;
  final String turkish;
  final String level;
  bool isFavorite;
  int correctCount;
  int wrongCount;
  DateTime lastReviewed;
  String status; // 'new', 'learning', 'mastered'
  String? userNote;
  bool isUserAdded;

  Word({
    required this.english,
    required this.turkish,
    required this.level,
    this.isFavorite = false,
    this.correctCount = 0,
    this.wrongCount = 0,
    DateTime? lastReviewed,
    this.status = 'new',
    this.userNote,
    this.isUserAdded = false,
  }) : lastReviewed = lastReviewed ?? DateTime.now();

  double get successRate {
    if (correctCount + wrongCount == 0) return 0.0;
    return correctCount / (correctCount + wrongCount);
  }

  String get difficulty {
    if (successRate > 0.8) return 'Kolay';
    if (successRate > 0.5) return 'Orta';
    return 'Zor';
  }
}
