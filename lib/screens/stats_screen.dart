import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../providers/app_provider.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late ConfettiController _confettiController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkForAchievements(WordProvider wordProvider) {
    final newAchievements = wordProvider.achievements.where(
      (a) =>
          a.isUnlocked &&
          a.unlockedAt!.isAfter(DateTime.now().subtract(Duration(seconds: 3))),
    );
    if (newAchievements.isNotEmpty &&
        Provider.of<AppProvider>(
          context,
          listen: false,
        ).settings.showConfetti) {
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordProvider = Provider.of<WordProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    _checkForAchievements(wordProvider);

    return Scaffold(
      backgroundColor: appProvider.settings.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'İstatistikler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appProvider.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab Seçimi
              Container(
                decoration: BoxDecoration(
                  color: appProvider.settings.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildTabButton('Genel', 0),
                    _buildTabButton('Başarımlar', 1),
                    _buildTabButton('Kelime Analiz', 2),
                  ],
                ),
              ),
              Expanded(
                child: _selectedTab == 0
                    ? _buildGeneralStats(wordProvider, appProvider)
                    : _selectedTab == 1
                    ? _buildAchievements(wordProvider, appProvider)
                    : _buildWordAnalysis(wordProvider, appProvider),
              ),
            ],
          ),

          // Konfeti efekti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final appProvider = Provider.of<AppProvider>(context);
    final isSelected = _selectedTab == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedTab = index),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? appProvider.primaryColor
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? appProvider.primaryColor
                    : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralStats(
    WordProvider wordProvider,
    AppProvider appProvider,
  ) {
    final stats = wordProvider.stats;
    final dailyGoal = appProvider.settings.dailyGoal;
    final progress = stats.todayStudied / dailyGoal;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Günlük Hedef Kartı
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appProvider.primaryColor,
                    appProvider.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Bugünkü İlerleme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${stats.todayStudied}/$dailyGoal kelime',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '${stats.currentStreak}',
                        'Gün Serisi',
                        Icons.local_fire_department_rounded,
                      ),
                      _buildStatItem(
                        '${stats.longestStreak}',
                        'En Uzun Seri',
                        Icons.emoji_events_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // İstatistik Grid
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Toplam Kelime',
                '${wordProvider.words.length}',
                Icons.library_books_rounded,
                Colors.blue,
                appProvider,
              ),
              _buildStatCard(
                'Doğru Cevaplar',
                '${stats.totalCorrect}',
                Icons.check_circle_rounded,
                Colors.green,
                appProvider,
              ),
              _buildStatCard(
                'Yanlış Cevaplar',
                '${stats.totalWrong}',
                Icons.cancel_rounded,
                Colors.red,
                appProvider,
              ),
              _buildStatCard(
                'Başarı Oranı',
                '${(stats.successRate * 100).toStringAsFixed(1)}%',
                Icons.trending_up_rounded,
                Colors.orange,
                appProvider,
              ),
              _buildStatCard(
                'Favoriler',
                '${wordProvider.words.where((w) => w.isFavorite).length}',
                Icons.favorite_rounded,
                Colors.pink,
                appProvider,
              ),
              _buildStatCard(
                'Zor Kelimeler',
                '${wordProvider.difficultWords.length}',
                Icons.warning_rounded,
                Colors.deepOrange,
                appProvider,
              ),
            ],
          ),
          SizedBox(height: 20),

          // Seviye Dağılımı
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seviye Dağılımı',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...['A1', 'A2', 'B1', 'B2'].map((level) {
                    final count = wordProvider.words
                        .where((w) => w.level == level)
                        .length;
                    final total = wordProvider.words.length;
                    final percentage = total > 0 ? (count / total * 100) : 0;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            child: Text(
                              'Seviye $level',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: count / total,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getLevelColor(level),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '$count (%${percentage.toStringAsFixed(1)})',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    AppProvider appProvider,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appProvider.settings.isDarkMode
              ? Colors.grey.shade800
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(
    WordProvider wordProvider,
    AppProvider appProvider,
  ) {
    final achievements = wordProvider.achievements;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: appProvider.settings.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? Colors.amber.shade100
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(achievement.icon, style: TextStyle(fontSize: 20)),
                ),
              ),
              title: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: achievement.isUnlocked
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.description),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.isUnlocked ? Colors.green : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${achievement.currentProgress}/${achievement.target}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: achievement.isUnlocked
                  ? Icon(Icons.verified_rounded, color: Colors.green)
                  : Icon(Icons.lock_rounded, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordAnalysis(
    WordProvider wordProvider,
    AppProvider appProvider,
  ) {
    final difficultWords = wordProvider.difficultWords.take(10).toList();
    final masteredWords = wordProvider.words
        .where((w) => w.status == 'mastered')
        .take(10)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zorlandığın Kelimeler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ...difficultWords
              .map((word) => _buildWordItem(word, appProvider))
              .toList(),

          SizedBox(height: 24),
          Text(
            'En İyi Bildiğin Kelimeler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ...masteredWords
              .map((word) => _buildWordItem(word, appProvider))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildWordItem(Word word, AppProvider appProvider) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          word.english,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(word.turkish),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(word.successRate * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Başarı', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getLevelColor(word.level).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: _getLevelColor(word.level)),
          ),
          child: Center(
            child: Text(
              word.level,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getLevelColor(word.level),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return Colors.green;
      case 'A2':
        return Colors.lightGreen;
      case 'B1':
        return Colors.orange;
      case 'B2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
