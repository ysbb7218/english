import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/word_card.dart';
import 'favorites_screen.dart';
import 'test_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'add_word_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String selectedLevel = 'All';
  String selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  void _clearSearch() {
    setState(() {
      searchQuery = '';
      _searchController.clear();
    });
  }

  List<Word> get filteredWords {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    return wordProvider.getFilteredWords(
      searchQuery,
      selectedLevel,
      selectedFilter,
    );
  }

  int get favoriteCount {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    return wordProvider.words.where((w) => w.isFavorite).length;
  }

  int get todayProgress {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    return wordProvider.stats.todayStudied;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final wordProvider = Provider.of<WordProvider>(context);

    return Scaffold(
      backgroundColor: appProvider.settings.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [appProvider.primaryColor, appProvider.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Sol: Logo + Başlık
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.white70],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: appProvider.primaryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'English Flashcards',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${filteredWords.length} kelime • ${wordProvider.stats.todayStudied}/${appProvider.settings.dailyGoal} günlük',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sağ: İkonlar
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // İstatistikler
                      IconButton(
                        icon: Icon(
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StatsScreen()),
                        ),
                      ),
                      SizedBox(width: 8),

                      // Favoriler
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FavoritesScreen(),
                                ),
                              ),
                            ),
                          ),
                          if (favoriteCount > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: appProvider.primaryColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  favoriteCount > 9 ? '9+' : '$favoriteCount',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 8),

                      // Quiz Butonu
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade500,
                              Colors.deepOrange.shade500,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.4),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.quiz_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TestScreen()),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),

                      // Ayarlar
                      IconButton(
                        icon: Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section - YENİ TASARIM!
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appProvider.primaryColor, appProvider.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Arama Çubuğu
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "İngilizce veya Türkçe kelime ara...",
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 15),
                      prefixIcon: Container(
                        margin: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Hızlı Filtre Butonları - YENİ TASARIM
                Container(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildModernFilterItem(
                        'Tümü',
                        'all',
                        Icons.all_inclusive_rounded,
                      ),
                      _buildModernFilterItem(
                        'Favoriler',
                        'favorites',
                        Icons.favorite_rounded,
                      ),
                      _buildModernFilterItem(
                        'Zor Kelimeler',
                        'difficult',
                        Icons.warning_rounded,
                      ),
                      _buildModernFilterItem(
                        'Tekrar Gerekli',
                        'for_review',
                        Icons.refresh_rounded,
                      ),
                      _buildModernFilterItem(
                        'Benim Eklediklerim',
                        'user_added',
                        Icons.person_rounded,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),

                // Seviye Filtreleri - YENİ TASARIM
                Container(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'A1', 'A2', 'B1', 'B2'].map((level) {
                      bool isSelected = selectedLevel == level;
                      Color levelColor = _getLevelColor(level);

                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () => setState(() => selectedLevel = level),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : levelColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? levelColor
                                      : Colors.white.withOpacity(0.4),
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: levelColor.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (level != 'All')
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? levelColor
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Text(
                                    level == 'All'
                                        ? 'Tüm Seviyeler'
                                        : 'Seviye $level',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isSelected
                                          ? levelColor
                                          : Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Kelime Listesi
          Expanded(
            child: filteredWords.isEmpty
                ? _buildEmptyState(appProvider)
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      final word = filteredWords[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: WordCard(
                          key: ValueKey(word.english),
                          word: word,
                          onFavoriteToggle: () {
                            final wordProvider = Provider.of<WordProvider>(
                              context,
                              listen: false,
                            );
                            wordProvider.toggleFavorite(word);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddWordScreen()),
        ),
        backgroundColor: appProvider.primaryColor,
        foregroundColor: Colors.white,
        child: Icon(Icons.add_rounded),
        elevation: 8,
      ),
    );
  }

  Widget _buildModernFilterItem(String label, String value, IconData icon) {
    final isSelected = selectedFilter == value;
    final appProvider = Provider.of<AppProvider>(context);

    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => setState(() => selectedFilter = value),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? appProvider.primaryColor : Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? appProvider.primaryColor : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'All':
        return Colors.deepPurple;
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

  Widget _buildEmptyState(AppProvider appProvider) {
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
              Icons.search_off_rounded,
              size: 70,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 28),
          Text(
            "Kelime bulunamadı",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: appProvider.settings.isDarkMode
                  ? Colors.white
                  : Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),
          Text(
            searchQuery.isNotEmpty
                ? "'$searchQuery' için sonuç yok"
                : "Bu filtrede kelime bulunamadı",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: appProvider.settings.isDarkMode
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 25),
          if (searchQuery.isNotEmpty ||
              selectedLevel != 'All' ||
              selectedFilter != 'all')
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: appProvider.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                shadowColor: appProvider.primaryColor.withOpacity(0.4),
              ),
              child: Text(
                'Filtreleri Temizle',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddWordScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Yeni Kelime Ekle',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
