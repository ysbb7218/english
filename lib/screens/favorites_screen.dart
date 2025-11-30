import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/word_card.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _searchQuery = '';
  String _selectedLevel = 'All';
  final TextEditingController _searchController = TextEditingController();

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  List<Word> get filteredFavorites {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    final favorites = wordProvider.words.where((w) => w.isFavorite).toList();

    var filtered = favorites;

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (word) =>
                word.english.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                word.turkish.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Seviye filtresi
    if (_selectedLevel != 'All') {
      filtered = filtered
          .where((word) => word.level == _selectedLevel)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final wordProvider = Provider.of<WordProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final favorites = filteredFavorites;

    return Scaffold(
      backgroundColor: appProvider.settings.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Favori Kelimelerim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: '  (${favorites.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: appProvider.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_rounded),
              onPressed: _showClearAllDialog,
              tooltip: 'Tümünü Kaldır',
            ),
        ],
      ),
      body: Column(
        children: [
          // Arama ve Filtre Çubuğu
          if (wordProvider.words.any((w) => w.isFavorite))
            Container(
              padding: EdgeInsets.all(16),
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
              child: Column(
                children: [
                  // Arama Çubuğu
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Favorilerde ara...",
                      prefixIcon: Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Seviye Filtreleri
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'A1', 'A2', 'B1', 'B2'].map((level) {
                        final isSelected = _selectedLevel == level;
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              level == 'All' ? 'Tümü' : 'Seviye $level',
                            ),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _selectedLevel = level),
                            backgroundColor: isSelected
                                ? appProvider.primaryColor
                                : Colors.grey.shade300,
                            selectedColor: appProvider.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

          // İstatistik Kartı (sadece favori varsa)
          if (favorites.isNotEmpty) ...[
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade500, Colors.purple.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Favori Kelimelerin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${favorites.length} kelime',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Toplam ${wordProvider.words.length} kelime içinden',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '%${((favorites.length / wordProvider.words.length) * 100).toInt()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Seviye Dağılımı
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['A1', 'A2', 'B1', 'B2'].map((level) {
                  int count = favorites.where((w) => w.level == level).length;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _getLevelColor(level).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getLevelColor(level).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            level,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getLevelColor(level),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getLevelColor(level),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
          ],

          // Favori Kelimeler Listesi
          Expanded(
            child: favorites.isEmpty
                ? _buildEmptyState(appProvider, wordProvider)
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final word = favorites[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: WordCard(
                          word: word,
                          onFavoriteToggle: () {
                            wordProvider.toggleFavorite(word);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppProvider appProvider, WordProvider wordProvider) {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: appProvider.settings.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 70,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 32),
          Text(
            wordProvider.words.any((w) => w.isFavorite)
                ? 'Filtreye uygun favori bulunamadı'
                : 'Henüz favori kelimen yok',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: appProvider.settings.isDarkMode
                  ? Colors.white
                  : Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 16),
          Text(
            wordProvider.words.any((w) => w.isFavorite)
                ? 'Farklı bir arama terimi veya seviye deneyin'
                : 'Beğendiğin kelimelerin yanındaki kalp ikonuna tıklayarak favorilere ekleyebilirsin',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: appProvider.settings.isDarkMode
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: appProvider.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ana Sayfaya Dön',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Tüm Favorileri Kaldır'),
          ],
        ),
        content: Text(
          'Tüm favori kelimelerinizi kaldırmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Tüm favorileri kaldır
              for (final word in wordProvider.words) {
                if (word.isFavorite) {
                  word.isFavorite = false;
                }
              }
              wordProvider.notifyListeners();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tüm favoriler kaldırıldı'),
                  backgroundColor: Colors.red.shade600,
                ),
              );
            },
            child: Text('Kaldır'),
          ),
        ],
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
