import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../providers/app_provider.dart';

class AddWordScreen extends StatefulWidget {
  @override
  _AddWordScreenState createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _turkishController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedLevel = 'A1';
  bool _addToFavorites = false;

  @override
  void dispose() {
    _englishController.dispose();
    _turkishController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveWord() {
    if (_formKey.currentState!.validate()) {
      final newWord = Word(
        english: _englishController.text.trim(),
        turkish: _turkishController.text.trim(),
        level: _selectedLevel,
        isFavorite: _addToFavorites,
        userNote: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        isUserAdded: true,
      );

      final wordProvider = Provider.of<WordProvider>(context, listen: false);
      wordProvider.addUserWord(newWord);

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${newWord.english}" kelimesi eklendi!'),
          backgroundColor: Colors.green,
        ),
      );

      // Formu temizle
      _formKey.currentState!.reset();
      _noteController.clear();
      setState(() {
        _selectedLevel = 'A1';
        _addToFavorites = false;
      });

      // Opsiyonel: Ana sayfaya dön
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: appProvider.settings.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Yeni Kelime Ekle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appProvider.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded),
            onPressed: _saveWord,
            tooltip: 'Kelimeyi Kaydet',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // İngilizce Kelime
                      TextFormField(
                        controller: _englishController,
                        decoration: InputDecoration(
                          labelText: 'İngilizce Kelime *',
                          prefixIcon: Icon(Icons.language_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen İngilizce kelime girin';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Türkçe Anlam
                      TextFormField(
                        controller: _turkishController,
                        decoration: InputDecoration(
                          labelText: 'Türkçe Anlam *',
                          prefixIcon: Icon(Icons.translate_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen Türkçe anlam girin';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Seviye Seçimi
                      DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: InputDecoration(
                          labelText: 'Seviye',
                          prefixIcon: Icon(Icons.school_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['A1', 'A2', 'B1', 'B2'].map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getLevelColor(level),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Seviye $level'),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedLevel = value!),
                      ),
                      SizedBox(height: 16),

                      // Not Alanı
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Not (Opsiyonel)',
                          prefixIcon: Icon(Icons.note_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),

                      // Favorilere Ekle
                      SwitchListTile(
                        title: Text('Favorilere Ekle'),
                        value: _addToFavorites,
                        onChanged: (value) =>
                            setState(() => _addToFavorites = value),
                        secondary: Icon(
                          Icons.favorite_rounded,
                          color: _addToFavorites ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appProvider.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded),
                      SizedBox(width: 8),
                      Text(
                        'Kelimeyi Kaydet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Bilgi Kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_rounded, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'İpucu',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Kendi kelimelerinizi ekleyerek kişisel kelime dağarcığınızı oluşturabilirsiniz. '
                        'Eklediğiniz kelimeler diğer kelimelerle birlikte quizlerde ve çalışma modlarında görünecektir.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
