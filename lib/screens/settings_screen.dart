import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/word_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final wordProvider = Provider.of<WordProvider>(context);

    return Scaffold(
      backgroundColor: appProvider.settings.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: appProvider.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Görünüm Ayarları
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
                    'Görünüm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // Koyu/Açık Mod
                  SwitchListTile(
                    title: Text('Koyu Mod'),
                    value: appProvider.settings.isDarkMode,
                    onChanged: (value) => appProvider.toggleDarkMode(),
                    secondary: Icon(Icons.dark_mode_rounded),
                  ),

                  // Tema Rengi
                  ListTile(
                    leading: Icon(Icons.palette_rounded),
                    title: Text('Tema Rengi'),
                    trailing: DropdownButton<String>(
                      value: appProvider.settings.themeColor,
                      onChanged: (value) =>
                          appProvider.updateThemeColor(value!),
                      items: [
                        DropdownMenuItem(
                          value: 'indigo',
                          child: Text('Çivit Mavi'),
                        ),
                        DropdownMenuItem(value: 'blue', child: Text('Mavi')),
                        DropdownMenuItem(value: 'green', child: Text('Yeşil')),
                        DropdownMenuItem(value: 'purple', child: Text('Mor')),
                        DropdownMenuItem(
                          value: 'orange',
                          child: Text('Turuncu'),
                        ),
                        DropdownMenuItem(value: 'red', child: Text('Kırmızı')),
                      ],
                    ),
                  ),

                  // Yazı Boyutu
                  ListTile(
                    leading: Icon(Icons.text_fields_rounded),
                    title: Text('Yazı Boyutu'),
                    trailing: DropdownButton<int>(
                      value: appProvider.settings.fontSize,
                      onChanged: (value) => appProvider.updateFontSize(value!),
                      items: [14, 16, 18, 20].map((size) {
                        return DropdownMenuItem(
                          value: size,
                          child: Text('$size pt'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Öğrenme Ayarları
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
                    'Öğrenme Ayarları',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // Günlük Hedef
                  ListTile(
                    leading: Icon(Icons.flag_rounded),
                    title: Text('Günlük Kelime Hedefi'),
                    trailing: DropdownButton<int>(
                      value: appProvider.settings.dailyGoal,
                      onChanged: (value) => appProvider.updateDailyGoal(value!),
                      items: [5, 10, 15, 20, 25, 30].map((goal) {
                        return DropdownMenuItem(
                          value: goal,
                          child: Text('$goal kelime'),
                        );
                      }).toList(),
                    ),
                  ),

                  // Konfeti Efektleri
                  SwitchListTile(
                    title: Text('Kutlama Efektleri'),
                    value: appProvider.settings.showConfetti,
                    onChanged: (value) => appProvider.toggleConfetti(),
                    secondary: Icon(Icons.celebration_rounded),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Veri Yönetimi
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
                    'Veri Yönetimi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // İstatistikleri Sıfırla
                  ListTile(
                    leading: Icon(
                      Icons.restart_alt_rounded,
                      color: Colors.orange,
                    ),
                    title: Text('İstatistikleri Sıfırla'),
                    onTap: () => _showResetStatsDialog(wordProvider),
                  ),

                  // Kullanıcı Kelimelerini Temizle
                  ListTile(
                    leading: Icon(Icons.delete_rounded, color: Colors.red),
                    title: Text('Eklenen Kelimeleri Sil'),
                    onTap: () => _showClearUserWordsDialog(wordProvider),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Uygulama Bilgisi
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
                    'Uygulama Bilgisi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  ListTile(
                    leading: Icon(Icons.info_rounded),
                    title: Text('Toplam Kelime'),
                    trailing: Text('${wordProvider.words.length}'),
                  ),

                  ListTile(
                    leading: Icon(Icons.person_rounded),
                    title: Text('Eklenen Kelimeler'),
                    trailing: Text('${wordProvider.userWords.length}'),
                  ),

                  ListTile(
                    leading: Icon(Icons.favorite_rounded),
                    title: Text('Favori Kelimeler'),
                    trailing: Text(
                      '${wordProvider.words.where((w) => w.isFavorite).length}',
                    ),
                  ),

                  ListTile(
                    leading: Icon(Icons.verified_rounded),
                    title: Text('Kazanılan Başarımlar'),
                    trailing: Text(
                      '${wordProvider.achievements.where((a) => a.isUnlocked).length}/${wordProvider.achievements.length}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetStatsDialog(WordProvider wordProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İstatistikleri Sıfırla'),
        content: Text(
          'Tüm istatistikleriniz sıfırlanacak. Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              // İstatistikleri sıfırla
              final newStats = wordProvider.stats;
              newStats.totalStudied = 0;
              newStats.totalCorrect = 0;
              newStats.totalWrong = 0;
              newStats.currentStreak = 0;
              newStats.longestStreak = 0;
              newStats.dailyProgress.clear();

              // Kelime istatistiklerini sıfırla
              for (final word in wordProvider.words) {
                word.correctCount = 0;
                word.wrongCount = 0;
                word.status = 'new';
              }

              // Başarımları sıfırla
              for (final achievement in wordProvider.achievements) {
                achievement.currentProgress = 0;
                achievement.isUnlocked = false;
                achievement.unlockedAt = null;
              }

              wordProvider.notifyListeners();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('İstatistikler sıfırlandı')),
              );
            },
            child: Text('Sıfırla', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearUserWordsDialog(WordProvider wordProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kelime Temizleme'),
        content: Text(
          'Eklediğiniz tüm kelimeler silinecek. Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              wordProvider.userWords.clear();
              wordProvider.notifyListeners();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Eklenen kelimeler silindi')),
              );
            },
            child: Text('Temizle', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
