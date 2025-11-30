import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../providers/app_provider.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late List<Word> quizWords;
  int currentIndex = 0;
  int score = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  String? _correctAnswer;
  late ConfettiController _confettiController;
  int _totalQuestions = 10;
  String _testMode = 'mixed'; // 'mixed', 'level', 'difficult', 'favorites'
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _initializeQuiz();
  }

  void _initializeQuiz() {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    List<Word> availableWords = [];

    switch (_testMode) {
      case 'level':
        availableWords = wordProvider.words
            .where((w) => w.level == _selectedLevel)
            .toList();
        break;
      case 'difficult':
        availableWords = wordProvider.difficultWords;
        break;
      case 'favorites':
        availableWords = wordProvider.words.where((w) => w.isFavorite).toList();
        break;
      case 'mixed':
      default:
        availableWords = List.from(wordProvider.words);
        break;
    }

    if (availableWords.isEmpty) {
      // Eğer uygun kelime yoksa, tüm kelimeleri kullan
      availableWords = List.from(wordProvider.words);
    }

    availableWords.shuffle();
    quizWords = availableWords
        .take(min(_totalQuestions, availableWords.length))
        .toList();

    setState(() {
      currentIndex = 0;
      score = 0;
      _isAnswered = false;
      _selectedAnswer = null;
      _correctAnswer = null;
    });
  }

  void answerQuestion(String selectedAnswer) {
    if (_isAnswered) return;

    final wordProvider = Provider.of<WordProvider>(context, listen: false);

    setState(() {
      _isAnswered = true;
      _selectedAnswer = selectedAnswer;
      _correctAnswer = quizWords[currentIndex].turkish;
    });

    final isCorrect = selectedAnswer == _correctAnswer;
    wordProvider.updateWordStats(quizWords[currentIndex], isCorrect);

    if (isCorrect) {
      score++;
    }

    // 1.5 saniye sonra sonraki soru
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (currentIndex < quizWords.length - 1) {
      setState(() {
        currentIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
        _correctAnswer = null;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    double successRate = score / quizWords.length;
    wordProvider.updateQuizStats(score, quizWords.length);

    // Perfect score için konfeti
    if (score == quizWords.length && appProvider.settings.showConfetti) {
      _confettiController.play();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: Colors.white,
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başarı ikonu
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: successRate >= 0.7
                      ? Colors.green.shade50
                      : successRate >= 0.5
                      ? Colors.orange.shade50
                      : Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: successRate >= 0.7
                        ? Colors.green.shade200
                        : successRate >= 0.5
                        ? Colors.orange.shade200
                        : Colors.red.shade200,
                    width: 4,
                  ),
                ),
                child: Icon(
                  successRate >= 0.7
                      ? Icons.celebration_rounded
                      : successRate >= 0.5
                      ? Icons.school_rounded
                      : Icons.autorenew_rounded,
                  size: 60,
                  color: successRate >= 0.7
                      ? Colors.green.shade600
                      : successRate >= 0.5
                      ? Colors.orange.shade600
                      : Colors.red.shade600,
                ),
              ),

              SizedBox(height: 24),

              // Başlık
              Text(
                'Test Tamamlandı!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),

              SizedBox(height: 16),

              // Skor
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      'SKORUN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$score / ${quizWords.length}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: successRate,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        successRate >= 0.7
                            ? Colors.green
                            : successRate >= 0.5
                            ? Colors.orange
                            : Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Mesaj
              Text(
                successRate >= 0.7
                    ? '🎉 Harika performans!'
                    : successRate >= 0.5
                    ? '👏 İyi iş çıkardın!'
                    : '💪 Daha çok çalışmalısın!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Başarı oranı: ${(successRate * 100).toInt()}%',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              SizedBox(height: 32),

              // Butonlar
              Row(
                children: [
                  // Tekrar dene
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: Colors.indigo.shade300),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _initializeQuiz();
                      },
                      child: Text(
                        'Tekrar Dene',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // Ana sayfa
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: Colors.indigo.withOpacity(0.4),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // dialog
                        Navigator.pop(context); // test screen
                      },
                      child: Text(
                        'Ana Sayfa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> getOptions() {
    final correct = quizWords[currentIndex].turkish;
    final wordProvider = Provider.of<WordProvider>(context, listen: false);

    // Doğru cevap hariç rastgele kelimeler
    final wrongOptions =
        wordProvider.words
            .where((w) => w.turkish != correct)
            .map((e) => e.turkish)
            .toList()
          ..shuffle();

    final options = wrongOptions.take(3).toList()..add(correct);
    options.shuffle();
    return options;
  }

  Color _getOptionColor(String option) {
    if (!_isAnswered) return Colors.white;

    if (option == _correctAnswer) {
      return Colors.green.shade50;
    } else if (option == _selectedAnswer && option != _correctAnswer) {
      return Colors.red.shade50;
    }
    return Colors.white;
  }

  Color _getOptionTextColor(String option) {
    if (!_isAnswered) return Colors.indigo.shade800;

    if (option == _correctAnswer) {
      return Colors.green.shade800;
    } else if (option == _selectedAnswer && option != _correctAnswer) {
      return Colors.red.shade800;
    }
    return Colors.grey.shade600;
  }

  Color _getOptionBorderColor(String option) {
    if (!_isAnswered) return Colors.indigo.shade200;

    if (option == _correctAnswer) {
      return Colors.green.shade400;
    } else if (option == _selectedAnswer && option != _correctAnswer) {
      return Colors.red.shade400;
    }
    return Colors.grey.shade300;
  }

  void _showTestSettings() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: appProvider.settings.isDarkMode
                    ? Colors.grey.shade800
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Ayarları',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Test Modu
                  Text(
                    'Test Modu:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _testMode,
                    isExpanded: true,
                    onChanged: (value) {
                      setDialogState(() {
                        _testMode = value!;
                        if (_testMode != 'level') {
                          _selectedLevel = null;
                        }
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'mixed',
                        child: Text('Karışık (Tüm Kelimeler)'),
                      ),
                      DropdownMenuItem(
                        value: 'level',
                        child: Text('Seviye Bazlı'),
                      ),
                      DropdownMenuItem(
                        value: 'difficult',
                        child: Text('Zor Kelimeler'),
                      ),
                      DropdownMenuItem(
                        value: 'favorites',
                        child: Text('Favori Kelimeler'),
                      ),
                    ],
                  ),

                  // Seviye Seçimi (sadece level modunda)
                  if (_testMode == 'level') ...[
                    SizedBox(height: 16),
                    Text(
                      'Seviye:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedLevel ?? 'A1',
                      isExpanded: true,
                      onChanged: (value) =>
                          setDialogState(() => _selectedLevel = value!),
                      items: ['A1', 'A2', 'B1', 'B2'].map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text('Seviye $level'),
                        );
                      }).toList(),
                    ),
                  ],

                  // Soru Sayısı
                  SizedBox(height: 16),
                  Text(
                    'Soru Sayısı:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  DropdownButton<int>(
                    value: _totalQuestions,
                    isExpanded: true,
                    onChanged: (value) =>
                        setDialogState(() => _totalQuestions = value!),
                    items: [5, 10, 15, 20].map((count) {
                      return DropdownMenuItem(
                        value: count,
                        child: Text('$count Soru'),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('İptal'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _initializeQuiz();
                          },
                          child: Text('Testi Başlat'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    if (quizWords.isEmpty) {
      return Scaffold(
        backgroundColor: appProvider.settings.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'İngilizce Test',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: appProvider.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_rounded, size: 80, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Test için yeterli kelime bulunamadı!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Lütfen daha fazla kelime ekleyin veya farklı bir test modu seçin.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _showTestSettings,
                child: Text('Test Ayarları'),
              ),
            ],
          ),
        ),
      );
    }

    final currentWord = quizWords[currentIndex];
    final options = getOptions();

    return Scaffold(
      backgroundColor: appProvider.settings.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'İngilizce Test',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: appProvider.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded),
            onPressed: _showTestSettings,
            tooltip: 'Test Ayarları',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Üst bilgi ve ilerleme
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skor
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.amber.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Soru sayısı
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Text(
                        '${currentIndex + 1}/${quizWords.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade800,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // İlerleme çubuğu
                LinearProgressIndicator(
                  value: (currentIndex + 1) / quizWords.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.indigo.shade600,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),

                SizedBox(height: 40),

                // Soru kartı
                Card(
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  shadowColor: Colors.indigo.withOpacity(0.3),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.shade500,
                          Colors.purple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '"${currentWord.english}"',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Seviye ${currentWord.level}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // Şıklar
                Expanded(
                  child: ListView(
                    children: options.map((option) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _isAnswered
                                  ? null
                                  : () => answerQuestion(option),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _getOptionColor(option),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getOptionBorderColor(option),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // İkon
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color:
                                            _isAnswered &&
                                                option == _correctAnswer
                                            ? Colors.green
                                            : _isAnswered &&
                                                  option == _selectedAnswer &&
                                                  option != _correctAnswer
                                            ? Colors.red
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              _isAnswered &&
                                                  option == _correctAnswer
                                              ? Colors.green
                                              : _isAnswered &&
                                                    option == _selectedAnswer &&
                                                    option != _correctAnswer
                                              ? Colors.red
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          _isAnswered &&
                                              option == _correctAnswer
                                          ? Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : _isAnswered &&
                                                option == _selectedAnswer &&
                                                option != _correctAnswer
                                          ? Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),

                                    SizedBox(width: 16),

                                    // Seçenek metni
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: _getOptionTextColor(option),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
}
