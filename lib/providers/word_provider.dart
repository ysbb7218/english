import 'package:flutter/material.dart';
import '../models/word.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../data/words.dart' as default_words;
import '../data/achievements.dart' as default_achievements;

class WordProvider with ChangeNotifier {
  List<Word> _words = [];
  UserStats _stats = UserStats();
  List<Achievement> _achievements = [];
  List<Word> _userWords = [];

  List<Word> get words => [..._words, ..._userWords];
  UserStats get stats => _stats;
  List<Achievement> get achievements => _achievements;
  List<Word> get userWords => _userWords;

  WordProvider() {
    _initializeData();
  }

  void _initializeData() {
    _words = List.from(default_words.words);
    _achievements = List.from(default_achievements.achievements);
    _updateAchievements();
  }

  void toggleFavorite(Word word) {
    final allWords = [..._words, ..._userWords];
    final index = allWords.indexWhere((w) => w.english == word.english);

    if (index != -1) {
      if (index < _words.length) {
        _words[index].isFavorite = !_words[index].isFavorite;
      } else {
        final userIndex = index - _words.length;
        _userWords[userIndex].isFavorite = !_userWords[userIndex].isFavorite;
      }
      _updateAchievementProgress(
        'favorite_collector',
        allWords.where((w) => w.isFavorite).length,
      );
      notifyListeners();
    }
  }

  void addUserWord(Word newWord) {
    _userWords.add(newWord);
    _userWords.sort((a, b) => a.english.compareTo(b.english));
    _updateAchievementProgress('vocabulary_master', words.length);
    notifyListeners();
  }

  void updateWordStats(Word word, bool isCorrect) {
    final allWords = [..._words, ..._userWords];
    final index = allWords.indexWhere((w) => w.english == word.english);

    if (index != -1) {
      Word wordToUpdate;
      if (index < _words.length) {
        wordToUpdate = _words[index];
      } else {
        wordToUpdate = _userWords[index - _words.length];
      }

      if (isCorrect) {
        wordToUpdate.correctCount++;
        _stats.totalCorrect++;
      } else {
        wordToUpdate.wrongCount++;
        _stats.totalWrong++;
      }

      wordToUpdate.lastReviewed = DateTime.now();

      // Öğrenme durumunu güncelle
      final successRate = wordToUpdate.successRate;
      if (successRate > 0.8) {
        wordToUpdate.status = 'mastered';
      } else if (successRate > 0.5) {
        wordToUpdate.status = 'learning';
      } else {
        wordToUpdate.status = 'new';
      }

      // Günlük ilerlemeyi güncelle
      _stats.updateDailyProgress(1);
      _updateAchievements();
      notifyListeners();
    }
  }

  void updateUserNote(Word word, String note) {
    final allWords = [..._words, ..._userWords];
    final index = allWords.indexWhere((w) => w.english == word.english);

    if (index != -1) {
      if (index < _words.length) {
        _words[index].userNote = note;
      } else {
        _userWords[index - _words.length].userNote = note;
      }
      notifyListeners();
    }
  }

  void deleteUserWord(Word word) {
    _userWords.removeWhere((w) => w.english == word.english);
    notifyListeners();
  }

  // Spaced Repetition için zor kelimeleri getir
  List<Word> get difficultWords {
    return words.where((word) => word.successRate < 0.5).toList();
  }

  // Öğrenilmeyi bekleyen kelimeler
  List<Word> get wordsToReview {
    final now = DateTime.now();
    return words.where((word) {
      final daysSinceReview = now.difference(word.lastReviewed).inDays;
      if (word.status == 'new') return daysSinceReview >= 0;
      if (word.status == 'learning') return daysSinceReview >= 1;
      if (word.status == 'mastered') return daysSinceReview >= 7;
      return false;
    }).toList();
  }

  // Test istatistiklerini güncelle
  void updateQuizStats(int correctAnswers, int totalQuestions) {
    if (correctAnswers == totalQuestions) {
      _updateAchievementProgress('perfect_score', 1);
    }
    _updateAchievementProgress('quiz_champion', 1);
  }

  // Başarımları güncelle
  void _updateAchievements() {
    _updateAchievementProgress('first_steps', _stats.totalStudied > 0 ? 1 : 0);
    _updateAchievementProgress('quick_learner', _stats.totalStudied);
    _updateAchievementProgress('vocabulary_master', words.length);
    _updateAchievementProgress('streak_beginner', _stats.currentStreak);
    _updateAchievementProgress('dedicated_learner', _stats.currentStreak);
  }

  void _updateAchievementProgress(String achievementId, int progress) {
    final achievement = _achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () =>
          Achievement(id: '', title: '', description: '', icon: '', target: 0),
    );

    if (achievement.id.isNotEmpty) {
      achievement.updateProgress(progress);
    }
  }

  // Filtrelenmiş kelimeler
  List<Word> getFilteredWords(
    String searchQuery,
    String selectedLevel,
    String filterType,
  ) {
    List<Word> filtered = words;

    // Arama
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (word) =>
                word.english.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                word.turkish.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Seviye filtresi
    if (selectedLevel != 'All') {
      filtered = filtered.where((word) => word.level == selectedLevel).toList();
    }

    // Özel filtreler
    switch (filterType) {
      case 'favorites':
        filtered = filtered.where((word) => word.isFavorite).toList();
        break;
      case 'difficult':
        filtered = filtered.where((word) => word.successRate < 0.5).toList();
        break;
      case 'for_review':
        filtered = wordsToReview;
        break;
      case 'user_added':
        filtered = userWords;
        break;
    }

    return filtered;
  }
}
